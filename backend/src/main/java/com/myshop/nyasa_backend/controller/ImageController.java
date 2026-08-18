package com.myshop.nyasa_backend.controller;

import com.myshop.nyasa_backend.dto.response.ApiResponse;
import com.myshop.nyasa_backend.service.ImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/images")
@RequiredArgsConstructor
public class ImageController {

    private final ImageService imageService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<String> upload(
            @RequestParam("file") MultipartFile file
    ) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Image file is required");
        }

        String imageUrl = imageService.upload(file);

        return ApiResponse.ok("Image uploaded successfully", imageUrl);
    }

    @DeleteMapping
    public ApiResponse<Void> delete(
            @RequestParam String imageUrl
    ) {
        imageService.delete(imageUrl);

        return ApiResponse.ok("Image deleted successfully", null);
    }
}