package com.bso.mavendemo.service;

import org.springframework.stereotype.Service;

@Service
public class HelloService {
    public String helloMessage() {
        return "Hi from HelloService 22";
    }
}
