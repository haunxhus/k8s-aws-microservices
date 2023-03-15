package com.tanerdiler.microservice.main.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(value = {ResourceNotFoundException.class})
    protected ResponseEntity<String> handleResourceNOtFoundException(ResourceNotFoundException ex) {
        HttpStatus httpStatus = HttpStatus.NOT_FOUND;
        log.error("Resource not found " + ex);
        return new ResponseEntity<>(ex.getMessage(), httpStatus);
    }

    @ExceptionHandler(value = {HandleResourceFailException.class})
    protected ResponseEntity<String> handleResourceNOtFoundException(HandleResourceFailException ex) {
        HttpStatus httpStatus = HttpStatus.BAD_REQUEST;
        log.error("Handle Resource fail " + ex);
        return new ResponseEntity<>(ex.getMessage(), httpStatus);
    }

}
