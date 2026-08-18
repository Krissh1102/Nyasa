package com.myshop.nyasa_backend.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ImageService {

    private final Cloudinary cloudinary;

    private static final String FOLDER = "nyasa/products";

    public String upload(MultipartFile file) {
        try {
            Map<?, ?> result = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap(
                    "folder", FOLDER,
                    "resource_type", "image"
            ));
            return (String) result.get("secure_url");
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload image to Cloudinary", e);
        }
    }

    public void delete(String imageUrl) {
        String publicId = extractPublicId(imageUrl);
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
        } catch (IOException e) {
            throw new RuntimeException("Failed to delete image from Cloudinary", e);
        }
    }

    // Extracts "nyasa/products/abc123" from a full Cloudinary secure_url
    private String extractPublicId(String imageUrl) {
        String withoutQuery = imageUrl.split("\\?")[0];
        String afterUpload = withoutQuery.substring(withoutQuery.indexOf("/upload/") + "/upload/".length());
        // strip version segment like v1699999999/
        String withoutVersion = afterUpload.replaceFirst("^v\\d+/", "");
        int dotIndex = withoutVersion.lastIndexOf('.');
        return dotIndex > 0 ? withoutVersion.substring(0, dotIndex) : withoutVersion;
    }
}