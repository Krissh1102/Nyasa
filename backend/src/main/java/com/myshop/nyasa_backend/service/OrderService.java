package com.myshop.nyasa_backend.service;

import com.myshop.nyasa_backend.dto.request.CreateOrderRequest;
import com.myshop.nyasa_backend.dto.request.OrderItemRequest;
import com.myshop.nyasa_backend.dto.request.UpdateOrderStatusRequest;
import com.myshop.nyasa_backend.dto.response.OrderResponse;
import com.myshop.nyasa_backend.entity.*;
import com.myshop.nyasa_backend.enums.OrderStatus;
import com.myshop.nyasa_backend.exception.BadRequestException;
import com.myshop.nyasa_backend.exception.ResourceNotFoundException;
import com.myshop.nyasa_backend.repository.OrderRepository;
import com.myshop.nyasa_backend.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final ProductService productService;
    private final InventoryService inventoryService;
    private final JwtUtil jwtUtil;

    /**
     * Guest checkout. Requires a phone-verification token proving the customer
     * completed OTP verification for this exact phone number. Prices and stock
     * are always re-derived from PostgreSQL - never trusted from the client.
     */
    @Transactional
    public OrderResponse createOrder(CreateOrderRequest req) {

        if (!jwtUtil.isValidPhoneToken(req.getVerificationToken(), req.getPhoneNumber())) {
            throw new BadRequestException("Phone number not verified. Please verify OTP again before checkout.");
        }

        Order order = Order.builder()
                .customerName(req.getCustomerName())
                .phoneNumber(req.getPhoneNumber())
                .address(req.getAddress())
                .totalAmount(BigDecimal.ZERO)
                .status(OrderStatus.PENDING)
                .build();

        BigDecimal total = BigDecimal.ZERO;

        for (OrderItemRequest itemReq : req.getItems()) {
            Product product = productService.findEntity(itemReq.getProductId());

            if (!Boolean.TRUE.equals(product.getIsActive())) {
                throw new BadRequestException("Product '" + product.getName() + "' is no longer available");
            }

            // Reserve stock now, inside this transaction - throws if insufficient
            inventoryService.reserveStock(product.getId(), itemReq.getQuantity());

            // Price is looked up from the DB right now, never from the client payload
            BigDecimal currentPrice = product.getPrice();

            OrderItem orderItem = OrderItem.builder()
                    .product(product)
                    .quantity(itemReq.getQuantity())
                    .price(currentPrice)
                    .build();
            order.addItem(orderItem);

            total = total.add(currentPrice.multiply(BigDecimal.valueOf(itemReq.getQuantity())));
        }

        order.setTotalAmount(total);
        order.addStatusEvent(OrderStatusHistory.builder()
                .status(OrderStatus.PENDING)
                .changedBy("SYSTEM")
                .build());

        order = orderRepository.save(order);
        return OrderResponse.from(order);
    }

    @Transactional(readOnly = true)
    public OrderResponse getById(Long id) {
        return OrderResponse.from(findEntity(id));
    }

    /** Guest order tracking: caller must know both the order id and the phone number used to place it. */
    @Transactional(readOnly = true)
    public OrderResponse trackOrder(Long id, String phoneNumber) {
        Order order = orderRepository.findByIdAndPhoneNumber(id, phoneNumber)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        return OrderResponse.from(order);
    }

    @Transactional(readOnly = true)
    public Order findEntity(Long id) {
        return orderRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found with id " + id));
    }

    @Transactional(readOnly = true)
    public Page<OrderResponse> list(OrderStatus status, Pageable pageable) {
        Page<Order> page = status != null
                ? orderRepository.findByStatus(status, pageable)
                : orderRepository.findAll(pageable);
        return page.map(OrderResponse::from);
    }

    /** Admin-only. Advances order status and records it in order_status_history. */
    @Transactional
    public OrderResponse updateStatus(Long id, UpdateOrderStatusRequest req, String changedByAdminEmail) {
        Order order = findEntity(id);

        if (order.getStatus() == OrderStatus.DELIVERED || order.getStatus() == OrderStatus.CANCELLED) {
            throw new BadRequestException("Cannot change status of a " + order.getStatus() + " order");
        }

        // If cancelling before delivery, release the reserved stock back to inventory
        if (req.getStatus() == OrderStatus.CANCELLED) {
            for (OrderItem item : order.getOrderItems()) {
                inventoryService.restock(item.getProduct().getId(), item.getQuantity());
            }
        }

        order.setStatus(req.getStatus());
        order.addStatusEvent(OrderStatusHistory.builder()
                .status(req.getStatus())
                .changedBy(changedByAdminEmail)
                .build());

        order = orderRepository.save(order);
        return OrderResponse.from(order);
    }
}
