package com.jlpt_mono.app.dto;

import com.jlpt_mono.app.entity.Category;
import lombok.Builder;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
public class CategoryResponse {
    private Long id;
    private String nameJp;
    private String nameZh;
    private String nameEn;
    @Builder.Default
    private List<CategoryResponse> children = new ArrayList<>();

    public static CategoryResponse from(Category category) {
        return CategoryResponse.builder()
                .id(category.getId())
                .nameJp(category.getNameJp())
                .nameZh(category.getNameZh())
                .nameEn(category.getNameEn())
                .build();
    }
}
