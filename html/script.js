let frames = [
    [
        [255, 0, 0],
        [0, 255, 0],
        [0, 0, 255],
        [255, 0, 0],
        [0, 255, 0],
    ],
    [
        [0, 255, 0],
        [0, 0, 255],
        [255, 0, 0],
        [0, 255, 0],
        [255, 0, 0],
    ],
    [
        [0, 0, 255],
        [255, 0, 0],
        [0, 255, 0],
        [255, 0, 0],
        [0, 255, 0],
    ],
    [
        [255, 0, 0],
        [0, 255, 0],
        [255, 0, 0],
        [0, 255, 0],
        [0, 0, 255],
    ]
];
let currentFrame = 0;

function getRGB(str) {
    const match = str.match(/rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/);
    return match ? {
        red: parseInt(match[1]),
        green: parseInt(match[2]),
        blue: parseInt(match[3])
    } : {};
}

function colorToText(bandElem, bandTextElem, color) {
    $(bandTextElem).css("fill", "#FFFFFF");
    if (color[0] === 0 && color[1] === 0 && color[2] === 0) {
        $(bandTextElem).text("OFF");
    } else if (color[0] === 255 && color[1] === 255 && color[2] === 255) {
        $(bandTextElem).text("WHITE");
    } else if (color[0] === 255 && color[1] === 255) {
        $(bandTextElem).text("YELLOW");
        $(bandTextElem).css("fill", "black");
    } else if (color[0] === 255) {
        $(bandTextElem).text("RED");
    } else if (color[1] === 255) {
        $(bandTextElem).text("GREEN");
        $(bandTextElem).css("fill", "black");
    } else if (color[2] === 255) {
        $(bandTextElem).text("BLUE");
    }
}

function cycleColor(bandNum) {
    let bandElem = $('#band' + (bandNum + 1));
    let bandTextElem = '#band' + (bandNum + 1) + "Text";

    let currentColor = getRGB(bandElem.css("fill"));
    if (currentColor.red === 0 && currentColor.blue === 0 && currentColor.green === 0) {
        currentColor.red = 255;
        currentColor.green = 0;
        currentColor.blue = 0;
    } else if (currentColor.red === 255 && currentColor.green === 255) {
        currentColor.red = 0;
        currentColor.green = 0;
        currentColor.blue = 0;
    } else if (currentColor.red === 255) {
        currentColor.red = 0;
        currentColor.green = 255;
        currentColor.blue = 0;
    } else if (currentColor.green === 255) {
        currentColor.red = 0;
        currentColor.green = 0;
        currentColor.blue = 255;
    } else if (currentColor.blue === 255) {
        currentColor.red = 255;
        currentColor.green = 255;
        currentColor.blue = 0;
    } else {
        currentColor.red = 255;
        currentColor.green = 255;
        currentColor.blue = 255;
    }
    bandElem.css("fill", "rgba(" + currentColor.red + "," + currentColor.green + "," + currentColor.blue + ", 0.9)");
    colorToText(bandElem, bandTextElem, [currentColor.red, currentColor.green, currentColor.blue]);

    frames[currentFrame][bandNum][0] = currentColor.red;
    frames[currentFrame][bandNum][1] = currentColor.green;
    frames[currentFrame][bandNum][2] = currentColor.blue;
    console.log("Setting frame " + currentFrame + " to " + frames[currentFrame][bandNum]);
}

$(document).ready(function () {
    $(document).keyup(function (e) {
        // Handling pressing arrow keys
        if (e.keyCode === 37) {
            if(currentFrame === 0)
                return;

            let selected = parseInt(frameSelectElm.val());
            if (selected === 1) {
                return;
            }

            frameSelectElm.val(selected - 1);
            setFrame(selected - 1);
            $('#currentFrame').text(selected - 1);

            currentFrame = selected - 2;
            e.preventDefault();
        }else if (e.keyCode === 39) {
            if(currentFrame === frames.length)
                return;

            let selected = parseInt(frameSelectElm.val());
            if (selected === frames.length) {
                return;
            }

            frameSelectElm.val(selected + 1);
            setFrame(selected + 1);
            $('#currentFrame').text(selected + 1);

            currentFrame = selected;
            e.preventDefault();
        }else if(e.keyCode === 32){
            $('#play').click();
        }
    });

    $('#band1Container').click(function () {
        cycleColor(0);
    });
    $('#band2Container').click(function () {
        cycleColor(1);
    });
    $('#band3Container').click(function () {
        cycleColor(2);
    });
    $('#band4Container').click(function () {
        cycleColor(3);
    });
    $('#band5Container').click(function () {
        cycleColor(4);
    });

    function setBandColor(frame, band) {
        let bandElem = '#band' + (band + 1);
        $(bandElem).css({fill: "rgba(" + frame[band][0] + ", " + frame[band][1] + ", " + frame[band][2] + ", 0.9)"});

        colorToText(bandElem, bandElem + "Text", frame[band]);
    }

    /**
     * Framenumber is 1-indexed
     * @param frameNumber
     */
    function setFrame(frameNumber) {
        setBandColor(frames[frameNumber - 1], 0);
        setBandColor(frames[frameNumber - 1], 1);
        setBandColor(frames[frameNumber - 1], 2);
        setBandColor(frames[frameNumber - 1], 3);
        setBandColor(frames[frameNumber - 1], 4);
    }

    let frameCount = frames.length;
    let frameSelectElm = $('#frameSelect');
    let playInterval = null;
    $('#totalFrames').text(frameCount);
    $('#currentFrame').text(1);

    $('#addFrame').click(function () {
        if (frameCount === 256) {
            alert('You cannot have more than 256 frames!');
            return;
        }

        if (frameCount === 1) {
            $('#removeFrame').attr('disabled', false);
        }

        frames.push([
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0],
        ]);
        frameCount = frames.length;
        $('#totalFrames').text(frameCount);

        $('#totalTime').text(frameCount * 0.5);

        $('#frameSelect').append($('<option>', {
            value: frameCount,
            text: "Frame " + frameCount
        }));
    });

    $('#dupeFrame').click(function () {
        if (frameCount === 256) {
            alert('You cannot have more than 256 frames!');
            return;
        }

        if (frameCount === 1) {
            $('#removeFrame').attr('disabled', false);
        }

        frames.push([
            frames[currentFrame][0],
            frames[currentFrame][1],
            frames[currentFrame][2],
            frames[currentFrame][3],
            frames[currentFrame][4],
        ]);
        frameCount = frames.length;
        $('#totalFrames').text(frameCount);

        $('#totalTime').text(frameCount * 0.5);

        $('#frameSelect').append($('<option>', {
            value: frameCount,
            text: "Frame " + frameCount
        }));

        currentFrame = frameCount - 1;
        setFrame(frameCount);
        $('#currentFrame').text(frameCount);
        frameSelectElm.val(frameCount);
    });

    $('#removeFrame').click(function () {
        currentFrame = 0;
        setFrame(1);
        frameSelectElm.val(1);
        $('#currentFrame').text(1);

        frames.pop();
        frameCount = frames.length;
        $('#totalFrames').text(frameCount);

        $('#frameSelect').children().last().remove();
        $('#totalTime').text(frameCount * 0.5);

        if (frameCount === 1) {
            $('#removeFrame').attr('disabled', true);
        }
    });

    $('#prevFrame').click(function () {
        let selected = parseInt(frameSelectElm.val());
        if (selected === 1) {
            return;
        }

        frameSelectElm.val(selected - 1);
        setFrame(selected - 1);
        $('#currentFrame').text(selected - 1);

        currentFrame = selected - 2;
    });

    $('#nextFrame').click(function () {
        let selected = parseInt(frameSelectElm.val());
        if (selected !== frameCount) {
            frameSelectElm.val(selected + 1);
            setFrame(selected + 1);
            $('#currentFrame').text(selected + 1);

            currentFrame = selected;
        }
    });

    $('#firstFrame').click(function () {
        frameSelectElm.val(1);
        setFrame(1);
        $('#currentFrame').text(1);
        currentFrame = 0;
    });

    $('#lastFrame').click(function () {
        frameSelectElm.val(frameCount);
        setFrame(frameCount);
        $('#currentFrame').text(frameCount);

        currentFrame = frameCount - 1;
    });

    $('#frameSelect').on('change', function () {
        let selected = frameSelectElm.val();
        currentFrame = selected - 1;
        $('#currentFrame').text(selected);
        setFrame(selected);
    });

    $('#play').click(function () {
        $('#removeFrame').attr('disabled', true);
        $('#addFrame').attr('disabled', true);
        $('#play').attr('disabled', true);
        $('#stop').attr('disabled', false);
        $('#prevFrame').attr('disabled', true);
        $('#nextFrame').attr('disabled', true);
        $('#firstFrame').attr('disabled', true);
        $('#lastFrame').attr('disabled', true);
        $('#export').attr('disabled', true);
        $('#save').attr('disabled', true);
        $('#dupeFrame').attr('disabled', true);
        $('#frameSelect').attr('disabled', true);

        let selected = 0;
        frameSelectElm.val(selected + 1);
        selected++;
        setFrame(selected);

        playInterval = setInterval(function () {
            if (selected === frameCount) {
                selected = 0;
                //clearInterval(interval);
            }

            frameSelectElm.val(selected + 1);
            selected++;
            $('#currentFrame').text(selected);
            setFrame(selected);
        }, 500);
    });

    $('#stop').click(function () {
        $('#removeFrame').attr('disabled', false);
        $('#addFrame').attr('disabled', false);
        $('#play').attr('disabled', false);
        $('#stop').attr('disabled', true);
        $('#prevFrame').attr('disabled', false);
        $('#nextFrame').attr('disabled', false);
        $('#firstFrame').attr('disabled', false);
        $('#lastFrame').attr('disabled', false);
        $('#export').attr('disabled', false);
        $('#save').attr('disabled', false);
        $('#dupeFrame').attr('disabled', false);
        $('#frameSelect').attr('disabled', false);

        clearInterval(playInterval);
    });

    setFrame(1);
    for (let i = 0; i < frameCount; i++) {
        $('#frameSelect').append($('<option>', {
            value: i + 1,
            text: "Frame " + (i + 1)
        }));
    }
    $('#totalTime').text(frameCount * 0.5);

    $('#save').click(function () {
        let data = {
            frames: frames,
            frameCount: frameCount
        };

        $.ajax({
            url: '/save',
            type: 'POST',
            data: JSON.stringify(data),
            contentType: 'application/json',
            success: function (data) {
                console.log(data);
            }
        });
    });

    $('#export').click(function () {
        $("body").append("<div id='exportDialog' style='width:100%; height:100%;position:absolute; top:0;left:0; background:rgba(0, 0, 0, 0.9);'>" +
            "<textarea id='exportData' readonly style='margin: 50px auto;display: block;width: 50%;height:50%;'></textarea>" +
            "<button id='closeExportDialog' style='margin: 50px auto;display: block;'>Close</button>" +
            "</div>");
        $('#exportData').click(function () {
            $(this).select();
        });
        $('#closeExportDialog').click(function () {
            $('#exportDialog').remove();
        });

        $('#exportData').val(JSON.stringify(frames));
    });

    function fillCurrentFrameWithColor(r, g, b) {
        // Fill animation frame with blue
        let frame = frames[currentFrame];
        for (let i = 0; i < frame.length; i++) {
            frame[i] = [r, g, b];
        }
        setFrame(currentFrame + 1);
    }

    $('#fillRed').click(function () {
        fillCurrentFrameWithColor(255, 0, 0);
    });

    $('#fillGreen').click(function () {
        fillCurrentFrameWithColor(0, 255, 0);
    });

    $('#fillBlue').click(function () {
        fillCurrentFrameWithColor(0, 0, 255);
    });

    $('#fillYellow').click(function () {
        fillCurrentFrameWithColor(255, 255, 0);
    });

    $('#fillClear').click(function () {
        fillCurrentFrameWithColor(0, 0, 0);
    });

    $('#fillRandom').click(function () {
        let frame = frames[currentFrame];
        for (let i = 0; i < frame.length; i++) {
            // Generated random integer between 0 and 3
            let r = Math.floor(Math.random() * 5);
            let red = r === 0 ? 255 : 0;
            let green = r === 1 ? 255 : 0;
            let blue = r === 2 ? 255 : 0;
            let yellow = r === 3;
            if (yellow) {
                frame[i] = [255, 255, 0];
            } else
                frame[i] = [red, green, blue];
        }
        setFrame(currentFrame + 1);
    });
});