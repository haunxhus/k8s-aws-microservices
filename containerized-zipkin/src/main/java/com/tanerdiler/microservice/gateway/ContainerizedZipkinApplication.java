package com.tanerdiler.microservice.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.zuul.EnableZuulProxy;
import zipkin2.server.internal.EnableZipkinServer;

@SpringBootApplication
@EnableZipkinServer
public class ContainerizedZipkinApplication
{
	public static void main(String[] args) {
		SpringApplication.run(ContainerizedZipkinApplication.class, args);
	}
}
