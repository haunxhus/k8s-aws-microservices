package com.tanerdiler.microservice.product.config;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.GenericFilterBean;

import brave.Span;
import brave.Tracer;
import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class SleuthConfig extends GenericFilterBean {

	private final Tracer tracer;

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {

		Span currentSpan = this.tracer.currentSpan();

		// for readability we're returning trace id in a hex form
		((HttpServletResponse) response).addHeader("X-B3-TraceId", currentSpan.context().traceIdString());

		chain.doFilter(request, response);
	}

}