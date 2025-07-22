---
layout: post
title: "Cannondale Scalpel HT dreambuild"
author: "Daniil"
tags: cycling engineering
excerpt_separator: <!--more-->
---

Hello there! I have finally decided to write a blog post! This story will be
about my first hard and expensive project, where I will describe
the planning hell, preparing headache and, eventually, building journey of my
first carbon XC race bicycle from scratch. I will walk you through all the
complexities I met along the way and the knowledge I found that helped me to
overcome them. Come and join me if you like exploring and building on your own!

<!--more-->

This story will be divided into a series of blog posts, because otherwise it may
turn into a book, and I am scared of writing books as for now. This blog post
will serve as a prologue that will smoothly start the story and outline the main
antagonist. There will be no difficult technical details for now. So, enjoy!

## Why Scalpel HT?

![cannondale-scalpel-ht-si-2022]({{ site.baseurl }}/assets/images/2025-07-05-scalpel-ht-building-story/cannondale-scalpel-ht-2022.jpg)
_Cannondale Scalpel HT 2022, source: Cannondale_

[Scalpel HT][scalpel-ht] is a Cannondaile's mountain bike family that targets XC
races and marathons. There is also [a brother][scalpel] called just "Scalpel"
that features rear suspension. Both are popular modern XC bikes families worth
choosing even for top world XC events.

Why Cannondale and Scalpel HT? At the time when I started the project I was not
a cycling expert and was not aware of all these world XC championships and all
the top brands like BMC, Canyon, Specialized, Trek, SCOTT, Cannondale, etc..
It was a time when I was chasing Bachelor's degree in engineering in Poland.
When you are an abroad student living in a dormitory - you don't have much
freedom in such expensive and technologically-complicated projects. Just check
out my room while building the bike:

![dorm-room-building-bike]({{ site.baseurl }}/assets/images/2025-07-05-scalpel-ht-building-story/dorm-room-building-bike.jpg)
_Somewhere in Poland, author: Daniil_

At this time, I prayed no one from the dormitory administration would come and
see what hell was going on in my room.

So, the focus during building was not on what I wanted, but on what I needed
(well... mostly). What did I need then? The things I considered when choosing
the components:

* One time investment.
* Service intervals and service complexity, that defines how much time per, for
  example, month I will needed to invest into servicing (cleaning, replacing,
  adjusting, etc.).
* Components durability and components costs, that defines how much money I
  will invest into the bike per, for example, month (like chain change, etc.).

If the goal was to only minimise things listed above, then it would be better
not to buy a bike at all. So there were also a few things that I had to adjust
to the costs:

* Performance on track (weight, gears, tyres, etc.).
* Comfort on longer rides (the longest rides for me are around 100 kilometers).

These of course are general definitions, I will cover them in detail in the
following chapters.

Getting back to [Scalpel HT](scalpel-ht) vs [Scalpel](scalpel). The thing is,
that the two most difficult and expensive things to service in every bike
(especially the expensive ones) are shocks and bearings. What are the two things
full suspension bikes do have that hardtails do not? Right, the rear shock and
suspension links that use bearings. Those two components significantly increase
all the things I wanted to minimize: the cost and the time needed for
servicing.

On the other hand, the rear suspension comes with comfort on longer unpaved
rides and better rear stability on technically hard elements. But you know what?
Sometimes I deserve those kicks in my ass when I oversleep some bumps on the
trail. On the technically complex trails with no rear suspension I really had to
get through all those hard downhill and uphill sections on my own legs learning
how to handle and how to choose the best way through hell.

Why Cannondale and not any other brand? The answer is simple - at the time
Cannondale had the cheapest framesets in Poland.

So, enough of the theory, and let's get to the real tech and the building fun.

[scalpel-ht]: https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel-ht
[scalpel]: https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel

## The frame, or where it all began

![scalpel-ht-frame]({{ site.baseurl }}/assets/images/2025-07-05-scalpel-ht-building-story/scalpel-ht-frame.png)
_Source: https://www.cannondale.com/en-eu/owners-manuals/-/media/files/manual-uploads/my21/021_138678_can_oms%20scalpel%20ht_en.pdf_

There is nothing special about the frame. It is a classical frame except for
the rear triangle, which is said to "eat" some bumps on trails. I am not an
expert of bike geometry versus human anatomy, so my choice was based on
argumentation logic like "the biggest is the fastest" (mostly because of my
height, which is 193 centimeters). Hence I chose the XL size (the biggest
available). The exact numbers can be found in the [Scalpel HT owners
manual][owners-manual].

What I was interested in were the numbers that define what components should be
installed:
* Fork:
  * Tapered or not tapered: **tapered**.
  * Head tube diameters:
    * Upper: **11/8in.**
    * Lower: **11/2in.**
  * Maximum fork length: **530 mm.**.
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
I will explain the, for example, `Integrated 1 1/8in-1.5in FSA Orbit C-40 ACB`
and other magic numbers later.

For other details like maximum rider weight or any frame-specific details that
are not important here, check the [Scalpel HT owners manual][owners-manual].

### Cannondale's Asymmetric integration

![tech-standarts-meme]({{ site.baseurl }}/assets/images/2025-07-05-scalpel-ht-building-story/tech-standarts-meme.png)

Among other things I had problems during researching, the Cannondale's
Asymmetric integration (I will call it Ai in this blog post) is the scariest.
Why? Because it changes everything in your bike build, and most exactly: the
wheels and transmission configuration.

What is Cannondale's Asymmetric Integration and why was it invented?

![ai-rear-triangle]({{ site.baseurl }}/assets/images/2025-07-05-scalpel-ht-building-story/ai-rear-triangle.jpg)
_Source: https://support.cannondale.com/hc/en-us/articles/219101107-Ai-Asymmetric-Integration_

In short, the main reason for it to be invented - is to strengthen the rear
wheel structure, by decreasing the difference between right and left rear wheel
spokes length. Though, it will not make the spokes on two sides perfectly the
same length, that would distribute the stress applied to the spokes equally,
because the spokes length difference depends on rear hub implementation-specific
parameters, it will significantly reduce the difference and increase rear wheel
stiffness. It was the first time I applied my school knowledge about geometry in
practice. So there will be some interesting things to discuss later, when
building the wheels.

While generally the idea makes sense and definitely has its benefits, it comes
with downsides: the cassette should be shifted 6 mm. to the right. Shifting the
cassette changes the chainline, which results in a need to correct it on the
chainring side, which should be shifted 6 mm to the right too. While the shift
for the cassette is not problematic, it just moves. To adjust the chainline on
the chainring side you have to play with the crankset and, probably, with the
bottom bracket. This comes with a lot of complications, especially taking into
account the "Cannondale's standarts".

In a few words: there are one or two possible combinations of bottom bracket and
crankset that are suitable for Cannondale's Ai and will match the new chainline.
And as I will explain later in the blogpost related to transmission, buying
specifically designed components from a specific manufacturer can result in
buying the entire transmission from these manufacturers. This comes with
significantly greater costs, sometimes lower performance and potential problems
with servicing and replacement in future.

I did not want to bind myself to any specific technology and components, and
wanted full freedom in customization. Hence, I should have checked whether my
frame has this technology, and if yes - how to omit all these proprietary
transmission standards. Finding the answer to these questions was a real
headache back then.

Why a headache? Because the bicycle world is not very standardized. The top-tier
bikes are overloaded with proprietary designs no one wants to share any numbers
about and all these "scetchy" marketing words. Consider for example [one of
Cannondale's
Scalpel](https://www.cannondalebikes.pl/rowery/gorskie/xc-race/scalpel/scalpel-lab71-c24035)
frame description:

> Scalpel LAB71, Series 0 Carbon construction, 120mm travel, Proportional
> Response Suspension and Geometry, FlexPivot Chainstay, full internal cable
> routing, 73mm BSA, 1.5" headtube with 1-1/8" upper reducer/internal cable
> guide, 148x12mm thru axle, 55mm chainline, UDH, post-mount disc – 160mm
> native.

Even now I am not sure what some of these words mean and how they affect the,
for example, transmission set up.

How did I figure out whether my frame has the Ai or not? First things first,
I checked the mentioned before description of [already existing
bikes](https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel-ht)
on similar frames. And I did not find the words `Ai Offset`, that means the
frames used in the bikes have the Ai. This was a glimmer of hope that
promised an easier build. But then, while reading forums, I found out that some
of the models of the same family might or might not have the Ai, and **there is
no clearly declared condition on that**. For example, this might depend on the
year the frame was produced, etc.. Compare for example the description of
[this][scalpel-carbon-4] (has the Ai in the description) and [this][scalpel-4]
(doesn't have the Ai in the description) Scalpels. The only difference seems to
be the chosen language of the site (the Polish or the English language) or used
domain name (.com and .pl)?

Because I bought a frameset, not a bike, and the frameset had no information
packed in - my paranoia raised an alarm. The reason: you must be 100% sure about
the Ai, unless you want to gamble when buying wheels and transmission that is
pretty expensive.

The final conclusion here for me was that my frame does not have the Ai. I have
figured out while building wheels and transmission. I will definitely mention it
several times in future and will precise things out.

[owners-manual]: https://www.cannondale.com/en-eu/owners-manuals/-/media/files/manual-uploads/my21/021_138678_can_oms%20scalpel%20ht_en.pdf
[scalpel-4]: https://www.cannondale.com/en-eu/bikes/mountain/cross-country/scalpel/scalpel-4
[scalpel-carbon-4]: https://www.cannondalebikes.pl/rowery/gorskie/xc-race/scalpel/scalpel-carbon-4-c24402m

## Summing up

So, the story begins with a frame. I think it is a classical beginning for a
bike build. The frame defines what fork you are going to use as well as how you
want to position yourself on the bike - that is the cockpit. After that come the
wheels, as they depend on both: the fork and the frame. And as final step - the
transmission, where you will be aligning the frame with the rear wheel.

Therefore, there will be three more blog posts:
* A small dive into forks and cockpits.
* Reinventing the wheel.
* Let it turn!

And that is it for now!

![maraton-gniewino-2025]({{ site.baseurl }}/assets/images/2025-07-05-scalpel-ht-building-story/maraton-gniewino-2025.jpg)

<center><em>We humans, we’re all the same. Every last one of us. For some it’s
drinking. For some it’s women. For some, even religion. Family. The king.
Dreams. Children. Power. All of us had to spend our lives drunk on something.
Else we’d have no cause to keep pushing on. Everyone was a slave to something.
</em> Kenny Ackermann, Attack on Titan</center>
