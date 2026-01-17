---
layout: post
title: "Scheduling unschedulable, FreeRTOS scheduler"
author: "Daniil"
tags: programming engineering operating_systems
excerpt_separator: <!--more-->
---

Hello there! Some time ago I was chasing Bachelor's degree in the Gdańsk
University of Technology. And as a thesis I choose my own topic: "Methods for
implementing control algorithms using embedded systems.". Sounds vague, isn't
it? But this was my first dive into low level programming, and I want to share
some of my thoughts and findings.

<!--more-->

### What is the scheduler?

![flagman]({{ site.baseurl }}/assets/images/2025-07-24-scheduling-introduction/flagman.png)
_Quickly created._

The main guest in this post will be **the scheduler** of an operating system.
The scheduler is like a traffic flagman on intersection, where the cars are your
applications you are running on your personal computer, smartphone or any
interractive piece of electronics. Depending on some canditions some cars will
be moving hence reaching their final destination, while other will be waiting.

There is a large number of specific schedulers that are designed for specific
systems (the interractive systems are the most popular example). But I will
focuse on the schedulers that serve a specific operating systems called Real
Time Operating Systems (aka. RTOS).

### Real time?

I think the definition should be explained briefly before continuing. Here are
some of the difinitions found on the internet:

From [the wikipedia.org][rtos-wiki]:

> Real-time computing (RTC) is the computer science term for hardware and
> software systems subject to a "real-time constraint", for example from event
> to system response. Real-time programs must guarantee response within
> specified time constraints, often referred to as "deadlines".

From [24765-2017 - ISO/IEC/IEEE][iso-24765-2017]:

> 3.3327<br>
> real-time
> 1. problem, system, or application that is concurrent and has timing
> constraints whereby incoming events must be processed within a given timeframe
> 2. pertaining to a system or mode of operation in which computation is
> performed during the actual time that an external process occurs, in order
> that the computation results can be used to control, monitor, or respond in a
> timely manner to the external process

From [TCRTS (aka. Technical Community on Real-Time Systems)][tcrts-real-time]:

> **Real-Time System**: is a computing system whose correct behavior depends not
> only on the value of the computation but also on the time at which outputs are
> produced.

These are just a few definitions that can be found on the internet, but I think
they explain the main point precise enough: the focuse in real time applications
is on time, and more precisely on the **time determinism**. What does the "time
determinism" mean? Well, shortly it means that every event arrival in time can
be computed and/or controlled, hence determined.

Therefore, by projecting the definition of real time systems on the operating
systems we get the real time operating systems also known as RTOSes. That is,
these are the operating systems where, among other important features, the time
determinism is **the most important**. This breaks the common misconception
about RTOSes: RTOSes do not focuse on **how fast** you will get the result, they
focuse on **when** you get the result.

[rtos-wiki]: https://en.wikipedia.org/wiki/Real-time_computing
[iso-24765-2017]: https://ieeexplore.ieee.org/document/8016712
[tcrts-real-time]: https://cmte.ieee.org/tcrts/education/terminology-and-notation/

### Why RTOS'es?

There is a great variety of operating systems out there. Why RTOSes then? The
operating system is a complex topic. Most of the time it has a large codedbase,
several layers of abstractions, large amount of APIs, etc.. And all of this
varies by the hardware architecture every operating system is built to run on
and specific software implementation.

Hence I wanted to skip all these huge general purpose operating systems and
all the edge case implementations. And the RTOSes are very popular and mostly
build according to microkernel architecture principles. That means they are
small, simple and most of the time have only the core components implemented,
including the scheduler. Moreover, most of the time, the scheduler is the main
focuse in RTOS'es.

So, the RTOS'es are just a shortcut to experiments with the scheduler.

## Where the scheduler lives?

![cpu-resources-multiplexing]({{ site.baseurl }}/assets/images/2025-07-24-scheduling-introduction/cpu-resources-multiplexing.svg)
_An architecture diagram. P.S. I do not know how the ARM Exception Levels got
here._

The above image is yet another TODO of the software architecture diagrams. But
with one difference: I put some arrows that outline how CPU resources are being
assigned in this software hierarhy:

1. The hypervisors are responsible for separating virtual machines environments,
  including its execution context. Hence, hypervisors typically have a separate
  chunk of code that contains either a static assignemnt of the CPU resources or
  a scheduler.
2. Hypervisors often are used to run several operating systems in a separated
  environments.
3. Sometimes hypervisors are used to launch bare-metal applications as well.
4. When an operating system is being launched on top of a hypervisor we have
  another layer, where the CPU resources are shared - the scheduler in the
  operating systems.

There are other architectures with more complex CPU resources sharing (e.g. the
nested virtualization), but I did not want to overcomplicate the intrudoction.
Going further - I want to drop the hypervisor from this post as well, as I have
not touched the nested scheduling yet. In fact, the RTOS'es archiotectures allow
to drop all drivers and services as well, and study the scheduling in a
laboratory environment, so the architecture becomes much simpler:

![cpu-resources-multiplexing-minimal]({{ site.baseurl }}/assets/images/2025-07-24-scheduling-introduction/cpu-resources-multiplexing-minimal.svg)
_Yet another architecture diagram._

### Quick guide into FreeRTOS

FreeRTOS is a micrekernel designed for real-time application on MCUs. To run
several tasks semultenuously on one core you need:

1. Add the starting point:

    ```c
    int main(void){

        while (1){}
    }
    ```

2. Add the tasks:

    ```c
    void Task1(void *pvParameters);
    void Task2(void *pvParameters);

    int main(void){
        while (1){}
    }

    void Task1 (void *pvParameters){

        while (1){
            vTaskDelay(pdMS_TO_TICKS( 500 ));
        }
        vTaskDelete(NULL);
    }

    void Task2 (void *pvParameters){

        while (1){
            vTaskDelay(pdMS_TO_TICKS( 1000 ));
        }
        vTaskDelete(NULL);
    }
    ```

3. Register the tasks:

    ```c
    void Task1(void *pvParameters);
    void Task2(void *pvParameters);

    int main(void){
        xTaskCreate(Task1, "Task1", TASK_STACK_LENGHT_WORDS, NULL, 1, NULL);
        xTaskCreate(Task2, "Task2", TASK_STACK_LENGHT_WORDS, NULL, 0, NULL);

        while (1){}
    }

    void Task1 (void *pvParameters){

        while (1){
            vTaskDelay(pdMS_TO_TICKS( 1 ));
        }
        vTaskDelete(NULL);
    }

    void Task2 (void *pvParameters){

        while (1){
            vTaskDelay(pdMS_TO_TICKS( 4 ));
        }
        vTaskDelete(NULL);
    }
    ```

4. Start the sceduler:

    ```c
    void Task1(void *pvParameters);
    void Task2(void *pvParameters);

    int main(void){
        xTaskCreate(Task1, "Task1", TASK_STACK_LENGHT_WORDS, NULL, 1, NULL);
        xTaskCreate(Task2, "Task2", TASK_STACK_LENGHT_WORDS, NULL, 0, NULL);

        vTaskStartScheduler();

        while (1){}
    }

    void Task1 (void *pvParameters){

        while (1){
            vTaskDelay(pdMS_TO_TICKS( 1 ));
        }
        vTaskDelete(NULL);
    }

    void Task2 (void *pvParameters){

        while (1){
            vTaskDelay(pdMS_TO_TICKS( 4 ));
        }
        vTaskDelete(NULL);
    }
    ```

5. Enjoy watching the tasks fight for the CPU time.

For more technical information reffer to the:
* [FreeRTOS documentation][freertos-docs].
* [FreeRTOS book][freertos-book].

[freertos-docs]: https://www.freertos.org/Documentation/02-Kernel/07-Books-and-manual/01-RTOS_book#freertos-reference-manual
[freertos-book]: https://www.freertos.org/Documentation/02-Kernel/07-Books-and-manual/01-RTOS_book#mastering-the-freertos-real-time-kernel---a-hands-on-tutorial-guide

### Launching the minimal build on QEMU

## Scheduling technics

### Scheduling in FreeRTOS

## Scheduler's anatomy

### FreeRTOS scheduler implementation

## Summing up

<center><em>TODO
</em> TODO </center>
