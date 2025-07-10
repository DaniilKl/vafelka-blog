---
layout: post
title: "Cannondale Scalpel HT dreambuild"
author: "Daniil"
tags: cycling engineering
excerpt_separator: <!--more-->
---

TODO Intro

<!--more-->

## Why Scalpel HT?

![cannondale-scalpel-ht-si-2022](/assets/images/2025-07-05-scalpel-ht-building-story/cannondale-scalpel-ht-2022.jpg)
_Cannondale Scalpel HT 2022, source: Cannondale_

[Scalpel HT][scalpel-ht] is a member of Cannondaile's mountain bike family that
targets XC races and marathones. There is also [a brother][scalpel] called just
"Scalpel" that features rear suspension. Both are popular modern XC bikes worth
choosing even for top world XC events.

Why Cannondale and Scalpel HT? At the time when I started the project I was not
a cycling expert and was not aware of all these world XC championships and all
the top brands like BMC, Canyon, Specialized, Trek, SCOTT, Cannondale, etc.. It
were times when I was chasing Bachelor's degree in engineering in Poland. When
you are an abroad student living in a dormitory - you have really not much
freedom in such expensive and technologically-complicated projects. Just check
out my room while building the bike:

![dorm-room-building-bike](/assets/images/2025-07-05-scalpel-ht-building-story/dorm-room-building-bike.jpg)
_Somewhere in Poland, author: Daniil_

These times I was praying nobody from dormitory administration would come and
see what a hell was going on in my room.

So, the focus during building was not on what I wanted, but on what I needed
(well... mostly). What did I need then? The things I considered when choosing
the components:

* One time investement.
* Service intervals and service complexity, that defines how much time per, for
  example, month I will needed to invest into servising (cleaning, replacing,
  adjusting, etc.).
* Components durability and components costs, that defines how much money I
  will invest into the bike per, for example, month (like chain change, etc.).

If the goal was to only minimise things listed above, then it would be better
not to buy a bike at all. So there were also a few things that I had to adjust
to the costs:

* Perfomance on track (weight, gears, tyres, etc.).
* Comfort on longer rides (the longest rides for me are around 100 kilometers).

These of course are general definitions, I will cover them in details in the
following chapters.

Getting back to [Scalpel HT](scalpel-ht) vs [Scalpel](scalpel). That happens,
that two the most difficult and expensive things to service in every bike
(espesially the expensive ones) are shocks and bearings. What two things that
full suspension bikes do have and hardtails do not? Right, the rear shock and
suspension links that use bearings. These two components drastically increase
all the things I wanted to minimize: the costs and the time needed for
servicing.

On the other hand rear suspension comes with comfort on longer unpaved rides and
a better rear stability on technically hard elements. But you know what?
Sometimes I deserve these kicks in my ass when I oversleep some bumps on the
trail. On the technically camplex trails with no rear suspension I really had to
get through all these hard downhill and uphill sections on my own legs learning
how to handle and how to choose the best way trough hell.

Why Cannondale and not any other brand? The answer is simple - these times
Cannondale had chippest framesets in Poland.

So, enogh of the teory, and lets get to the real tech and the building fun.

[scalpel-ht]: https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel-ht
[scalpel]: https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel

## The frame

![scalpel-ht-frame](/assets/images/2025-07-05-scalpel-ht-building-story/scalpel-ht-frame.png)
_Source: https://www.cannondale.com/en-eu/owners-manuals/-/media/files/manual-uploads/my21/021_138678_can_oms%20scalpel%20ht_en.pdf_

There is nothing special in the frame, it is a classical frame oxcept from the
rear triangle, that is said to "eat" some bumps on trails. I am not an expert of
bike geaometry, so my choise was based on argumentation "the biggest is the
fastest" (mostly because of my height, which is 193 centimeters). Hence I chose
the XL size. The exact numbers can be found in the [Scalpel HT owners
manual][owners-manual].

What I was interested in are the numbers that define what components should be
installed:
* Fork:
  * Tapered or not tapered: **tapered**.
  * Head tube diameters:
    * Upper: **11/8in.**
    * Lower: **11/2in.**
  * Maximum fork lenght: **530 mm.**.
* Headset type: **Integrated 1 1/8in-1.5in FSA Orbit C-40 ACB**.
* Bottom bracket: **83 mm. PF30**.
* Seatpost:
  * Diameter: **27.2 mm.**.
  * Minimal insert length: **100 mm.**.
* Rear axle: **Speed Release UDH/148x12x1.0P 173.5mm OL**.
* Tyre size: **29 x 2.35in**.
* Brake mount:
  * Type: **post mount**.
  * Disk brake sizes: **160/180 mm.**.

These numbers and letters will be very important when choosing the components.
I will explain them later.

For other details like maximum rider weight, or any frame-specific details,
check the [Scalpel HT owners manual][owners-manual].

### Cannondale's Assymetric integration

![tech-standarts-meme](/assets/images/2025-07-05-scalpel-ht-building-story/tech-standarts-meme.png)

Among other things I had problems during researching, the Cannondales Assymetric
integration (I will call it Ai in this blog post) is the most scariest. Why?
Because it changes everything in your bike build, and most exactly: the wheels
and transmission configuration.

What is the Cannondale's Assymetric Integration and why was it invented?

![ai-rear-triangle](/assets/images/2025-07-05-scalpel-ht-building-story/ai-rear-triangle.jpg)
_Source: https://support.cannondale.com/hc/en-us/articles/219101107-Ai-Asymmetric-Integration_

If I understood correctly, the main reason for it to be invented - is to
strenghten the rear wheel structure, by decreasing difference between the right
and left rear wheel spokes length. Thought, it will not make the spokes
on two sides perfectly the same length, that would distribute the stress applied
to the spokes equally, because the spokes length difference depends on rear hub
implementation-specific parameters. It will definitely significantly reduce the
difference and increase rear wheel stiffness.

While generally the idea make sense and defenitely has its benefits, it comes
with downsides: the cassette should be shifted 6 mm. to the right. Shifting the
cassette changes the chainline, that results in a need to correct it on
crankset/buttom braket side, that should be shifted 6 mm to the right too. While
the shift for the cassette is not problematic, it just moves. Adjusting the
crankset and buttom braket to match the new chainline is more tricky.

In a few wards: there are one or two possible combinations of buttom braket and
crankset that are suitable for Cannondale's Ai and will match the new chainline.
And as I will explain later in [the transmission chapter](#transmission), buying
specifically designed components from a specific manufacturers may cause to buy
entire transmission from these manufacturers. This comes with sagnificantly
greater costs, sometimes lower perfomance and potential problems with servising
and replacement in future.

I did not want to bind myself to any specific technology and components, and
wanted full freedom in customization. Hence, I should have checked whether my
frame has this technology, and if yes - how to ommit all these proprietary
transmission standarts. Finding the answer to these questions was a real
headache back then.

Why a headache? Because the bicycle world is not very standartized. The top-tier
bikes are overloaded with proprietary designs no one whant to share any numbers
about and all these "scetchy" marketing words. Consider for example [one of
Cannondale's
Scalpels](https://www.cannondalebikes.pl/rowery/gorskie/xc-race/scalpel/scalpel-lab71-c24035)
frame desciption:

> Scalpel LAB71, Series 0 Carbon construction, 120mm travel, Proportional
> Response Suspension and Geometry, FlexPivot Chainstay, full internal cable
> routing, 73mm BSA, 1.5" headtube with 1-1/8" upper reducer/internal cable
> guide, 148x12mm thru axle, 55mm chainline, UDH, post-mount disc – 160mm
> native.

Even now I am not sure what 45% of these words mean and how do they affect the,
for example, transmission set up.

How did I figure out whether my frame has the Ai or not? Thirst things first,
I checked the mentioned before description of [already existing
bikes](https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel-ht)
on similar frames. And I did not faund the words `Ai Offset`, that mean, that
the frame has the Ai. This was a a glimmer of hope that promised an easier
build. But then I found out, that 

[owners-manual]: https://www.cannondale.com/en-eu/owners-manuals/-/media/files/manual-uploads/my21/021_138678_can_oms%20scalpel%20ht_en.pdf

## Forks and headseds

TODO

## Transmission

TODO

## Cockpit

TODO

## Wheels

TODO

## Summing up

TODO
