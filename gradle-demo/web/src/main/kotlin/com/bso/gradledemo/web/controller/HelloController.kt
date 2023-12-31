package com.bso.gradledemo.web.controller

import com.bso.gradledemo.service.HelloService
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/hello")
class HelloController(
    private val helloService: HelloService
) {

    @GetMapping
    fun hello(): String {
        return helloService.helloMessage()
    }
}