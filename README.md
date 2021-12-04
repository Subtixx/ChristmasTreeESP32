# ChristmasTreeESP32

This is my first ever public PCB build. Version 0.1 is ordered from JLCPCB and should be here in a couple of days of writing this (12/03/2021).

Since this is quite early in the development of this project, the PCB can contain issues so be aware! In the future I'd love to have more control over the LEDs. Currently the tree only has 5 "zones" as seen in the preview of the software. I'd love to support individual adressing of the LEDs to create even better animations.

As I am no electronic engineer the PCB does look ugly and can contain some non-standard things. Also after placing the order with JLCPCB, I have discovered that the silkscreen of the RGB LEDs are cut off, woops my mistake. Also I could not figure out how to get rid of the ESP32 Silkscreen.

The whole board was designed using EasyEDA.

- Create animations with up to 256 frames! Thats a 128 Seconds long animation! (This still needs testing if all of this fits in the ESP32 code)

# Why?

There are a number of soldering kits out there for a christmas tree as a PCB. However all of them are flawed in my opinion, they're missing an ESP32! (And are annoying since they're not calming at all!).
This is why I created a christmas tree PCB with an ESP32 and RGB LEDs.

# WiFi Setup

1. Enter the SSID of your Wifi in [WiFiCredentials.h:1](https://github.com/Subtixx/ChristmasTreeESP32/blob/6ed7a89fb9c6c5deb8025a748663b42830a94d5e/esp32_code/WiFiCredentials.h#L1)
2. Enter the password of your Wifi in [WiFiCredentials.h:2](https://github.com/Subtixx/ChristmasTreeESP32/blob/6ed7a89fb9c6c5deb8025a748663b42830a94d5e/esp32_code/WiFiCredentials.h#L2)

# PCB Preview

<table>
  <tr>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/144643475-46dab2a0-32f6-418d-850d-f22997feaaa3.png" style="float:left;" />
      <br />
      Bottom View
    </td>
    <td>
      <img src="https://user-images.githubusercontent.com/20743379/144644482-c9d8dd02-7b3c-48c4-b41e-87ac5af607c9.png" style="float:right;"/>
      <br />
      Top View
    </td>
  </tr>
</table>


# Webpage Preview

![Preview](https://user-images.githubusercontent.com/20743379/144642977-bbb2b022-0c0c-4441-a916-1a5c6091e8bc.png)

# Issues with the current board

- I have not checked for the pinout of the ESP32... So I assume there are some reserved GPIO pins connected :/.

# Technical explanation

The JQuery script sents a POST request with all of the frames of animation. The animation frames look like this
```json
[
    [1, 0, 0, 0, 0],
    [2, 0, 0, 0, 0],
    [3, 0, 0, 0, 0],
    [4, 0, 0, 0, 0],
    [0, 0, 0, 0, 0]
]
```

It's a 2D Array with the first dimension being the frame of animation and the second being the color of a "band" (I call the different LED groups bands).
So in this example its a 5 frame animation (2.5 seconds long as one frame takes roughly 500 ms). With the following values
1. Red
2. Green
3. Blue
4. Yellow
5. Off
