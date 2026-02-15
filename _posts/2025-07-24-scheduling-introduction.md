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

### Launching a minimal build on QEMU

> Note: This chapter contains some scary traces. If you do not understand smth.
> \- please reffer to QEMU documentation and man pages and search for `-d exec`.
> For me the fact that this debug option gives you the information about
> executed C functions is enogh.

You can launch a minimal demo from my graduate work repository by following the
following steps:

1. Download the pre-compiled ELF:

    ```bash
    wget https://github.com/DaniilKl/GraduateWork/raw/46e5e9ca415f71cd50629712d33d7f8538e86fde/Code/LM3S6965_GCC_QEMU/FreeRTOS_QEMU.elf
    ```

    > Note: This ELF has been compiled from
    > [here](https://github.com/DaniilKl/GraduateWork/tree/46e5e9ca415f71cd50629712d33d7f8538e86fde/Code/LM3S6965_GCC_QEMU)
    > using a modified FreeRTOS kernel 202212.01 from
    > [here.](https://github.com/DaniilKl/FreeRTOS/tree/ae4a4ffcb8ead71b5d3f868a1da514be54e35821)

2. Launch the QEMU:

    ```bash
    timeout 5s qemu-system-arm -kernel ./FreeRTOS_QEMU.elf -s -machine lm3s6965evb -nographic -d exec -D qemu.log < /dev/null &
    ```

    > Note: I used `QEMU emulator version 10.1.3 (qemu-10.1.3-1.fc43). The
    > `timeout 5s` is needed because otherwise the QEMU call will flood the
    > `qemu.log` file with traces.

After that you will have the `qemu.log` file with the following types of
content:

* Some system tasks (note, that I will hide some parts of the traces for
  convenience in the following code blocks):

    ```text
    (...)
    Trace 0: 0x7aadb800dd80 [00800400/0000129a/00000110/ff000000] prvInitialiseTaskLists
    Trace 0: 0x7aadb800d600 [00800400/00001458/00000110/ff000000] vListInitialise
    (...)
    Trace 0: 0x7aadb8010480 [00800400/0000017e/00000110/ff000000] xTaskCreate
    Trace 0: 0x7aadb8010700 [00800400/00001b86/00000110/ff000000] main
    Trace 0: 0x7aadb8001d40 [00800400/000000f0/00000110/ff000000] xTaskCreate
    Trace 0: 0x7aadb8002100 [00800400/000015b8/00000110/ff000000] pvPortMalloc
    Trace 0: 0x7aadb8002540 [00800400/0000070c/00000110/ff000000] vTaskSuspendAll
    Trace 0: 0x7aadb80028c0 [00800400/000015f0/00000110/ff000000] pvPortMalloc
    Trace 0: 0x7aadb80037c0 [00800400/00000728/00000110/ff000000] xTaskResumeAll
    Trace 0: 0x7aadb8003c80 [00800400/000018cc/00000110/ff000000] vPortEnterCritical
    (...)
    ```

* Some scheduler-related tasks:

    ```text
    (...)
    Trace 0: SysTick_Handler
    Trace 0: SysTick_Handler
    Trace 0: xTaskIncrementTick
    Trace 0: xTaskIncrementTick
    Trace 0: SysTick_Handler
    Trace 0: SysTick_Handler
    Trace 0: vPortEnterCritical
    Trace 0: vPortEnterCritical
    Trace 0: xTaskResumeAll
    Trace 0: xTaskResumeAll
    Trace 0: xTaskIncrementTick
    Trace 0: xTaskResumeAll
    Trace 0: vPortExitCritical
    Trace 0: vPortExitCritical
    Trace 0: xTaskResumeAll
    Trace 0: vTaskDelay
    Trace 0: PendSV_Handler
    Trace 0: PendSV_Handler
    Trace 0: vTaskSwitchContext
    (...)
    ```

* The `Task1` and `Task2` we created before!

    ```text
    (...)
    Trace 0: Task1
    Trace 0: vTaskDelay
    (...)
    Trace 0: PendSV_Handler
    Trace 0: Task2
    Trace 0: vTaskDelay
    (...)
    Trace 0: SysTick_Handler
    Trace 0: vTaskDelay
    Trace 0: Task1
    (...)
    ```

Actually if we take a closer look on the traces, we can find the momments, when
scheduler switches between `Task1` and `Task2` (I have deleted some parts of the
traces for convenience):

```text
Trace 0: Task1 <- Task1 is being executed
Trace 0: vTaskDelay <- Task1 enters its delay function
Trace 0: vTaskDelay
Trace 0: prvAddCurrentTaskToDelayedList
Trace 0: uxListRemove
Trace 0: prvAddCurrentTaskToDelayedList <- Task1 is being delayed
Trace 0: prvAddCurrentTaskToDelayedList
Trace 0: prvAddCurrentTaskToDelayedList
Trace 0: vTaskDelay
Trace 0: vPortEnterCritical
Trace 0: vPortEnterCritical
Trace 0: xTaskResumeAll
Trace 0: xTaskResumeAll
Trace 0: vPortExitCritical
Trace 0: vPortExitCritical
Trace 0: xTaskResumeAll
Trace 0: vTaskDelay
Trace 0: PendSV_Handler
Trace 0: PendSV_Handler
Trace 0: vTaskSwitchContext <- Scheduler switches between Task1 and Task2
Trace 0: PendSV_Handler
Trace 0: PendSV_Handler
Trace 0: PendSV_Handler
Trace 0: Task2 <- Task2 is being executed
```

I will do some enquiry on what is going on during such a switch later.

## Scheduler's anatomy

For the sake of the next chapter to be undertood in the easiest possible way I
need to get back to the theory for a moment.

![scheduler-anathomy]({{site.baseurl}}/assets/images/2025-07-24-scheduling-introduction/context-switching.png)
_Created while waiting for update to Fedora 43, I will reference this diagra as
"diagram 1"_

The image above presents **my understanding** of a OS code responsible for task
switching. That is, not all code that is being executed during context switch
should be called "scheduler". There are other pieces of code being executed that
are responsible for other critical features in the OS: **the code that triggers
the switch** (the green blocks on the diagram above), and the **dispatcher** (the
yellow blocks on the diagram above). But lets find these pieces of code in
FreeRTOS kernel.

## FreeRTOS scheduler

Now that we know a bit about the code responsible for task switching - we can
try and find it in the FreeRTOS source code.

<details><summary> A quick digression </summary>

<br>

{% markdown %}

While preparing the part about FreeRTOS scheduler I got a problem: somehow,
after I have switched to Fedora 43 I got problems with the image I built before
the update. And here where the good-old debugging skills help solve the problem.

In MCU world there is not a lot of logs like in Linux systems. Sometimes the
board just seems dead, because the issue occurred at the very beginning of
software execution. But in my case I had QEMU! Here what I got from QEMU with
`-d exec`.

{% highlight text %}
Trace 0: xPortStartScheduler
Trace 0: xPortStartScheduler
Linking TBs 0x7fbeb0015f80 index 1 -> 0x7fbeb0016540
Trace 0: xPortStartScheduler
Linking TBs 0x7fbeb0016540 index 1 -> 0x7fbeb0016780
Trace 0: xPortStartScheduler
Trace 0: xPortStartScheduler
Linking TBs 0x7fbeb00168c0 index 1 -> 0x7fbeb00169c0
Trace 0: xPortStartScheduler
Linking TBs 0x7fbeb00169c0 index 0 -> 0x7fbeb0016b40
Trace 0: xPortStartScheduler
Linking TBs 0x7fbeb0016b40 index 0 -> 0x7fbeb0016b40
Trace 0: xPortStartScheduler
{% endhighlight %}

It was stuck somewhere inside `xPortStartScheduler`, at the most critical
section of the FreeRTOS startup - scheduler start. And the QEMU with `-d
in_asm` showed:

{% highlight text %}
----------------
IN: xPortStartScheduler
0x0000182c:  e7fe       b        #0x182c
{% endhighlight %}

So a branch to itself, huh? It was a high time for a big guns - GDB with [GDB
dashboard](https://github.com/cyrus-and/gdb-dashboard). After a few minutes of
debugging I landed in the `xPortStartScheduler` on the following line from the
FreeRTOS file `task.c`:

{% highlight text %}
─── Source ─────────────────────────────────────────────────────────────────────────────────────────────
 404          {
 405              /* Check the FreeRTOS configuration that defines the number of
 406               * priority bits matches the number of priority bits actually queried
 407               * from the hardware. */
 408              configASSERT( ( portMAX_PRIGROUP_BITS - ulMaxPRIGROUPValue ) == configPRIO_BITS );
 409          }
 410          #endif
 411  
 412          /* Shift the priority group value back to its position within the AIRCR
 413           * register. */
{% endhighlight %}

After a few seconds I came to a conclusion that `configPRIO_BITS` has incorrect
value assigned. As one can see the `cmp` on address `0x00001814` compres two
values: the value of the `r3` which is the result of `portMAX_PRIGROUP_BITS -
ulMaxPRIGROUPValue` and the `8` constant value which is the value assigned to
`configPRIO_BITS`:

{% highlight text %}
─── Assembly ───────────────────────────────────────────────────────────────────────────────────────────
 0x00001808  xPortStartScheduler+82  cmp	r3, #128	@ 0x80
 0x0000180a  xPortStartScheduler+84  beq.n	0x17ec <xPortStartScheduler+54>
 0x0000180c  xPortStartScheduler+86  ldr	r3, [pc, #124]	@ (0x188c <xPortStartScheduler+214>)
 0x0000180e  xPortStartScheduler+88  ldr	r3, [r3, #0]
 0x00001810  xPortStartScheduler+90  rsb	r3, r3, #7
 0x00001814  xPortStartScheduler+94  cmp	r3, #8
 0x00001816  xPortStartScheduler+96  beq.n	0x182e <xPortStartScheduler+120>
 0x00001818  xPortStartScheduler+98  mov.w	r3, #5
 0x0000181c  xPortStartScheduler+102 msr	BASEPRI, r3
 0x00001820  xPortStartScheduler+106 isb	sy
─── Breakpoints ────────────────────────────────────────────────────────────────────────────────────────
[1] break at 0x000017bc in /home/danik/Documents/Projects/GraduateWork/Code/FreeRTOS/FreeRTOS/Source/portable/GCC/ARM_CM3/port.c:364 for xPortStartScheduler hit 1 time
─── Registers ──────────────────────────────────────────────────────────────────────────────────────────
           r0 0x00000001           r1 0x00000002             r2 0x2000ff10           r3 0x00000003
           r4 0x00000000           r5 0x00000000             r6 0x00000000           r7 0x2000ff70
           r8 0x00000000           r9 0x00000000            r10 0x00000000          r11 0x00000000
          r12 0x00000008           sp 0x2000ff70             lr 0x00000693           pc 0x00001814
         xpsr 0x81000000          msp 0x2000ff70            psp 0x00000000      primask 0x00000000
      control 0x00000000      basepri 0x00000005      faultmask 0x00000000
─── Source ─────────────────────────────────────────────────────────────────────────────────────────────
 404          {
 405              /* Check the FreeRTOS configuration that defines the number of
 406               * priority bits matches the number of priority bits actually queried
 407               * from the hardware. */
 408              configASSERT( ( portMAX_PRIGROUP_BITS - ulMaxPRIGROUPValue ) == configPRIO_BITS );
 409          }
 410          #endif
 411  
 412          /* Shift the priority group value back to its position within the AIRCR
 413           * register. */
{% endhighlight %}

And in case the values do match the execution jumps to address `0x0000182e` and
the scheduler is being initialized, otherwise it continues execution to
`0x00001818` that is a part of the port-specific function `vPortRaiseBASEPRI`
written in inline assembly that actually resulted in the "branch to itself"
instruction `b #0x182c`.

The solution was simple: assign value `3` to `configPRIO_BITS`. I am not sure
how much time I would have spent without GDB.

![gdb-good-boy]({{ site.baseurl }}/assets/images/2025-07-24-scheduling-introduction/gdb-good-boy.png)

This was the time when I have had been guessing why it worked before.

{% endmarkdown %}

</details>

<br>

Back then, when I have been starting my thesis, I did not know about QEMU yet,
so I had to compile the FreeRTOS on some real hardware (I had a STM Nucleo-64
with STM32F401RE MCU in my disposition back then) and go through an entire
FreeRTOS code up to running tasks to catch how the scheduler-related code and
variables are being initialized and then used during runtime. It was pretty
harsh warm up considering my close to zero knowledge about such systems. But now
I have the stack of knowledge and needed infrastructure from the completed
thesis and we can start from a lower entry level.

I will explain the reason I used QEMU instead of real hardware in my thesis
later, when I will approach the scheduler alghoritms analysis, so the problem
will be more clear. For the impation one: read the part "5.1 Używana platforma"
of [my thesis][thesis-pdf] for the reason of using QEMU, and the part "5.2.1
Problemy i założenia" of [my thesis][thesis-pdf] for the consequences of using
QEMU.

### The system initialization

Now I can get back to the `FreeRTOS_QEMU.elf` I have presented in [Launching
a minimal build on QEMU](#launching-a-minimal-build-on-qemu) and inspect the
`qemu.log` file generated there from the very beginning. Apart from other
FreeRTOS functions lets focuse on the following functions:

> Note: You can delete some useless information from the `qemu.log` by execution
> `:%s/0: [0-9]x[0-9a-zA-Z \[\/]*]/0:` in Neovim. This will make analysis
> easier.

```text
Trace 0: ResetISR
(...)
Trace 0: main
Trace 0: xTaskCreate
(...)
Trace 0: prvInitialiseNewTask
(...)
Trace 0: vListInitialiseItem
(...)
Trace 0: prvAddNewTaskToReadyList
(...)
Trace 0: prvInitialiseTaskLists
(...)
Trace 0: main
Trace 0: xTaskCreate
(...)
Trace 0: main
Trace 0: vTaskStartScheduler
Trace 0: xTaskCreate
(...)
Trace 0: xPortStartScheduler
(...)
Trace 0: vPortSetupTimerInterrupt
(...)
Trace 0: xPortStartScheduler
Trace 0: prvPortStartFirstTask
(...)
Trace 0: SVC_Handler
(...)
Trace 0: Task2
(...)
```

> Note: `(...)` means I have hidden some lines from `qemu.log` that are not
> worth presenting, e.g. memory init. functions or other functions that are not
> important from system point of view.

Going from the first function to the last:

* `ResetISR`: CPU [reset handler][reset-handler] located at adress 0 in [its. interrupt service
  routine vector][reset-location] (at least for ARM Cortex-M3 on which the ELF
  is built upon). This is the place from where we get into `main()` after CPU
  reset.
* The first `main`: The `main()` where the tasks are being registered and the
  FreeRTOS scheduler is being started. An example can be found in the [previous
  chapter](#launching-a-minimal-build-on-qemu).
* The first `xTaskCreate`: [The place][xtaskcreate-location] where the `Task1`
  is being initialized and registered to FreeRTOS. Apart from the actual `Task1`
  staff (the `prvInitialiseNewTask`, `vListInitialiseItem` and the
  `prvAddNewTaskToReadyList`) one additional function is being called: the
  `prvInitialiseTaskLists` wich creates and initializes the task queue (the
  `D3` from the `diagram 1`).
* The second `main`: At this point the task queue has been created and the
  `Task1` has been added to it.
* The second `xTaskCreate`: The place where the `Task2` is being initialized and
  registered to FreeRTOS (that is, being added to the task queue).
* The third `main`: At this point the task queue contain two tasks: `Task1` and
  `Task2`.
* The `vTaskStartScheduler`: [The place][vtaskstartscheduler-location] where
  scheduler is started, that does the following:
  * Calls the `xTaskCreate` again to create an ["idle task"][idle-location] that
    is being executed if there are no other tasks that are ready to be executed.
    You can inspect the `qemu.log` for `prvIdleTask` - this is the actual "idle
    task".
  * Then goes inside the [MPU-specific routine][xportstartscheduler-location]
    `xPortStartScheduler`, which does configuration and launches the SysTick
    interrupt (the `vPortSetupTimerInterrupt`) and switching execution to the
    first task in the task queue (the `S7` from the `diagram 1`; the
    `prvPortStartFirstTask`).
* The `SVC_Handler`: The `prvPortStartFirstTask` "yelds" to the low-level
  dispatcher step `S7` from the `diagram 1` to load the state of the
  to-be-executed task from the queue (for the classic FreeRTOS scheduler it is
  the task with the higher priority during registration) - `Task2`.

At this point the system has been initialized and running: the scheduler
switches execution between tasks using classic FreeRTOS policy, and the tasks
execute.

The important note here is that every time the `prvAddNewTaskToReadyList()` and
`prvInitialiseNewTask()` are being called the scheduler's code is being executed
to determine, whether the newly-registered task should be executed next or
should be placed in the task queue. Whether there is a need to execute scheduler
code during task initialization actually depends on the scheduler policy being
used. For example, lets use an analogy from medicine to explain this.

You have probably met two strategies used for providing treatment to injured
individuals in clinics:

* First come, first served (aka. FCFS or FIFO): A new person comes and sees the
  only queue with several peoples already waiting. The person knows the rules -
  he should join as a last one in the queue.

  ![fifo]({{site.baseurl}}/assets/images/2025-07-24-scheduling-introduction/fifo.png)

* [Triage][triage] or priority queues: A new person comes and is being assigned
  to a specific queue depending on the policy used by this clinic. Depending on
  the priority assigned - the person will be treated sooner or later.

  ![triage]({{site.baseurl}}/assets/images/2025-07-24-scheduling-introduction/triage.png)

Here are some examples:

* Priority assignment of a classic FreeRTOS scheduler:
  [link][freertos-priority].
* Priority recomputation for RM (aka. Rate Monotonic) scheduler I integrated
  into FreeRTOS kernel: [link][rm-priority].
* Priority assignment of a DARTS (aka. Dynamic Real Time Task Scheduling)
  scheduler I integrated into FreeRTOS kernel: [link][darts-priority].

As you can see, the way the task receives the priority during registration and
the task queue implementation depends on the scheduler policy. Hence I will
describe the implementation of these pieces of system code alongside the
specific scheduler policies implementations.

The `vPortSetupTimerInterrupt()` and the `prvPortStartFirstTask()` should be
inpected closely, though. As the names of the function contain `Port` it means
they are hardware-specific and can be found
[here][vportsetuptimerinterrupt-location] and
[here][prvportstartfirsttask-location].

The `vPortSetupTimerInterrupt()` sets up
the SysTick interrupt frequency using [configCPU_CLOCK_HZ][configCPU_CLOCK_HZ]
and [configTICK_RATE_HZ][configTICK_RATE_HZ], you can read more about this in
[FreeRTOS reference manual][freertos-reference-manual]. The SysTick is a
[periodic interrupt][systick-handler] that periodically [triggers
rescheduling][systick-trigger] (hence it is the trigger for the workflow from
the `diagram 1`). There are other places that trigger FreeRTOS rescheduling in
the FreeRTOS kernel source code. All of these places could be recognized by
yelding the [PendSV handler][pendsv-location].

The `prvPortStartFirstTask()` prepares the CPU for the state of the
to-be-executed task and [yelds][prvportstartfirsttask-yeld] to the [PendSV
handler][pendsv-location] to load the state of the to-be-executed task
(according to `S7` from the `diagram 1`) and switches execution to it
(according to `S8` from the `diagram 1`).

[reset-handler]: https://github.com/DaniilKl/GraduateWork/blob/46e5e9ca415f71cd50629712d33d7f8538e86fde/Code/LM3S6965_GCC_QEMU/src/startup.c#L86
[reset-location]: https://github.com/DaniilKl/GraduateWork/blob/46e5e9ca415f71cd50629712d33d7f8538e86fde/Code/LM3S6965_GCC_QEMU/src/startup.c#L21
[xtaskcreate-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/tasks.c#L1028
[vtaskstartscheduler-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/tasks.c#L2421
[idle-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/tasks.c#L4012
[xportstartscheduler-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L355
[triage]: https://en.wikipedia.org/wiki/Triage
[freertos-priority]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/tasks.c#L1401
[rm-priority]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/tasks.c#L1270
[darts-priority]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/tasks.c#L1514
[vportsetuptimerinterrupt-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L775
[prvportstartfirsttask-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L334
[configCPU_CLOCK_HZ]: https://github.com/DaniilKl/GraduateWork/blob/46e5e9ca415f71cd50629712d33d7f8538e86fde/Code/LM3S6965_GCC_QEMU/Include/FreeRTOSConfig.h#L60
[configTICK_RATE_HZ]: https://github.com/DaniilKl/GraduateWork/blob/46e5e9ca415f71cd50629712d33d7f8538e86fde/Code/LM3S6965_GCC_QEMU/Include/FreeRTOSConfig.h#L61C9-L61C27
[freertos-reference-manual]: https://www.freertos.org/media/2018/FreeRTOS_Reference_Manual_V10.0.0.pdf
[systick-handler]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L526
[systick-trigger]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L539
[pendsv-location]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L489
[prvportstartfirsttask-yeld]: https://github.com/DaniilKl/FreeRTOS-Kernel/blob/5c09db63d6bc5af2f68a0a5a8ee91946dc8acc40/portable/GCC/ARM_CM3/port.c#L345

### Switching between tasks



## Summing up

[thesis-pdf]: https://github.com/DaniilKl/GraduateWork/blob/main/Docs/Thesis/PDFs/GraduateWork.pdf

<center><em>TODO
</em> TODO </center>
