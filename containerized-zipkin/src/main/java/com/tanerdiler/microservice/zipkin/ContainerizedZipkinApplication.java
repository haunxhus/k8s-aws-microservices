package com.tanerdiler.microservice.zipkin;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import zipkin2.server.internal.EnableZipkinServer;

// https://www.baeldung.com/tracing-services-with-zipkin
@SpringBootApplication
@EnableZipkinServer
public class ContainerizedZipkinApplication {
	public static void main(String[] args) {
		
		SpringApplication.run(ContainerizedZipkinApplication.class, args);
	}
}
