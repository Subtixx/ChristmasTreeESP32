<div id="top"></div>

<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://user-images.githubusercontent.com/20743379/144643475-46dab2a0-32f6-418d-850d-f22997feaaa3.png" alt="Logo" width="80">
  </a>

  <h3 align="center">ChristmasTreeESP32</h3>

  <p align="center">
    A PCB Christmas tree using an ESP32 and 12 RGB LEDs
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#why-have-i-created-this">Why have I created this?</a></li>
    <li><a href="#pcb-preview">PCB Preview</a></li>
    <li><a href="#webpage-preview">Webpage Preview</a></li>
    <li><a href="#android-app">Android App</a></li>
    <li><a href="#wifi-setup">WiFi Setup</a></li>
    <li><a href="#issues-with-the-current-board">Issues with the current board</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

This is a christmas tree as PCB with RGB LEDs. It is controlled using an ESP32 and contains 12 RGB LEDs. Which can be configured in pairs of 2 so it has 6 different "zones" for colors.

The software can support up to 256 frames of animation (While a frame of animation is roughly 500ms long). The biggest animation I have tested had however only 20 frames.

**Before downloading the gerber files and ordering a PCB please take a look at [Issues with the current board](#issues-with-the-current-board), since this was my first ever PCB build I have made some mistake in the design which are outlined in the file linked above.**

The whole board was designed using EasyEDA. v2 will be designed in CircuitMaker if it will ever come out.
<p align="right">(<a href="#top">back to top</a>)</p>

# Why have I created this?

I know there are a number of soldering kits out there for a christmas tree as a PCB. However in my opinion those are lifeless and annoying. I had ordered one for christmas last year and it's not calming at all. The LEDs change color rapidly and in no order. 

I wanted a tree which looked more realistic, had the ability to change animations and could possibly also display several colors and not just red and green.

This is why I created a christmas tree PCB with an ESP32 and RGB LEDs.

<p align="right">(<a href="#top">back to top</a>)</p>

# PCB Preview

<table>
  <tr>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/147234915-8612cca9-ca1c-4a5f-a9b0-aa396973b72c.png" width="256" />
      <br />
      Bottom View
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/147234861-5d1d6595-4663-4edd-9ff1-2820745a7108.png" width="256" />
      <br />
      Top View
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/147234603-8eb69877-f5bf-40c1-b8d4-10e1267f85d4.png" width="256" />
      <br />
      Layout View
    </td>
  </tr>
</table>

<p align="right">(<a href="#top">back to top</a>)</p>

# Webpage Preview

_(Only frontend part is done)_

<img src="https://user-images.githubusercontent.com/20743379/144642977-bbb2b022-0c0c-4441-a916-1a5c6091e8bc.png" width="256" />

<p align="right">(<a href="#top">back to top</a>)</p>

# Android App

<table>
  <tr>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/145888885-788755b9-a393-4fc6-85ac-a924e099b9a1.png" width="256" style="float:left;" />
      <br />
      Main view
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/145889906-aa3e399e-f073-4acf-a8c9-6ca06bc6ad15.png" width="256" style="float:right;"/>
      <br />
      Settings view
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/145889624-89141aae-3e7c-4b9b-8181-3ff21f58e5d7.png" width="256" style="float:right;"/>
      <br />
      My files view
    </td>
  </tr>
</table>

<p align="right">(<a href="#top">back to top</a>)</p>

# WiFi Setup

1. Enter the SSID of your Wifi in [WiFiCredentials.h:1](https://github.com/Subtixx/ChristmasTreeESP32/blob/6ed7a89fb9c6c5deb8025a748663b42830a94d5e/esp32_code/WiFiCredentials.h#L1)
2. Enter the password of your Wifi in [WiFiCredentials.h:2](https://github.com/Subtixx/ChristmasTreeESP32/blob/6ed7a89fb9c6c5deb8025a748663b42830a94d5e/esp32_code/WiFiCredentials.h#L2)

<p align="right">(<a href="#top">back to top</a>)</p>

# Issues with the current board

**NOTE:** As I am no electronic engineer the PCB does look ugly and can contain some non-standard things. Also after placing the order with JLCPCB, I have discovered that the silkscreen of the RGB LEDs are cut off, woops my mistake. Also I could not figure out how to get rid of the ESP32 Silkscreen.

All issues should be fixed with this new version.

<del>
- No idea why but I thought the PCB would be much much bigger than it is. It's smaller than the commercial one I got for christmas last year from ebay which was a huge disappointment to me.

- I have not checked for the pinout of the ESP32... So I assume there are some reserved GPIO pins connected :/.

- Pin 35 is connected.. However Pin 35 cannot be an output.

- Some resistors are in series and not connected to the LED. Identified ones are:
  - Pin 17
- The used part for the ESP32 has the wrong footprint (atleast the one I bought AZDelivery ESP32).. It works when bending while soldering but it should be fixed.

- It is missing an LED on the top of the tree. It looks odd when having the tree turned on without one.

- I have not used any ground plane. No idea if this is critical or if this makes me stupid. But I've connected the grounds for all LEDs using traces. Thinking about this one after the fact makes me feel dumb.

- The slot on the trunk is too tight, PCBs are too thick to fit in there.

- Not an issue but a note on my design, I didn't want to "harm" the look and feel of the tree. This is why I have only populated the front side with components.

</del>

<p align="right">(<a href="#top">back to top</a>)</p>

# Technical explanation

A post request has to be made to http://[IPofESP]/post with a JSON Encoded body. An example animation would look like this:
```json
[
    [1, 0, 0, 0, 0],
    [2, 0, 0, 0, 0],
    [3, 0, 0, 0, 0],

    [4, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
]
```

It's a 2D Array with the first dimension being the frame of animation and the second being the color of a LED group.
So in this example its a 5 frame animation (2.5 seconds long as one frame takes roughly 500 ms). With the following values
1. Red
2. Green
3. Blue
4. Yellow
5. Off


<p align="right">(<a href="#top">back to top</a>)</p>
