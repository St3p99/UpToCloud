package unical.dimes.uptocloud.controller;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.service.DocumentService;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;
import java.util.List;

@RestController
@RequestMapping("${base-url}/search")
public class SearchController {

    private final DocumentService documentService;

    @Autowired
    public SearchController(DocumentService documentService) {
        this.documentService = documentService;
    }

    @Operation(method = "getRecentFilesOwned", summary = "Get recent files owned")
    @GetMapping(value = "/recent")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getRecentFilesOwned(@AuthenticationPrincipal Jwt principal) {
        try {
            List<Document> result = documentService.getRecentFilesOwned(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "getRecentFilesSharedWithMe", summary = "Get recent files shared with me")
    @GetMapping(value = "/recent-read-only")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getRecentFilesSharedWithMe(@AuthenticationPrincipal Jwt principal) {
        try {
            List<Document> result = documentService.getRecentFilesSharedWithMe(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }
}
