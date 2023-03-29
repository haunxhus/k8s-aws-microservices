package com.example.minioconnectionjava17.error;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class ErrorHandle {

    @Value("#{new Boolean('${application.mode.debug}')}")
    private boolean isDebugMode;

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleUnwantedException(Exception e) {
        e.printStackTrace();

        String errorMessage = "Unknow error";
        if(isDebugMode) {
            errorMessage = e.getMessage();
        }

        return ResponseEntity.status(500).body(errorMessage);
    }
}
