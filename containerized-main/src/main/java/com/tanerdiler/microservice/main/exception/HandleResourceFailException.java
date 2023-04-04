package com.tanerdiler.microservice.main.exception;

public class HandleResourceFailException extends RuntimeException{

    public HandleResourceFailException(String message) {
        super(message);
    }
}
