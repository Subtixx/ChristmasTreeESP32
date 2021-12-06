class Color {
    static OFF = new Color(0, 0, 0);
    static WHITE = new Color(255, 255, 255);

    static RED = new Color(255, 0, 0);
    static GREEN = new Color(0, 255, 0);
    static BLUE = new Color(0, 0, 255);
    static YELLOW = new Color(255, 255, 0);

    #r;
    #g;
    #b;

    constructor(r, g, b) {
        this.#r = r;
        this.#g = g;
        this.#b = b;
    }

    getRed() {
        return this.#r;
    }

    getGreen() {
        return this.#g;
    }

    getBlue() {
        return this.#b;
    }

    toString() {
        return `rgba(${this.#r}, ${this.#g}, ${this.#b}, 0.9)`;
    }

    getName() {
        if (this.valueOf() === Color.OFF.valueOf()) {
            return "OFF";
        } else if (this.valueOf() === Color.WHITE.valueOf()) {
            return "WHITE";
        } else if (this.valueOf() === Color.YELLOW.valueOf()) {
            return "YELLOW";
        } else if (this.valueOf() === Color.RED.valueOf()) {
            return "RED";
        } else if (this.valueOf() === Color.GREEN.valueOf()) {
            return "GREEN";
        } else if (this.valueOf() === Color.BLUE.valueOf()) {
            return "BLUE";
        }

        throw new Error("Unknown color " + this.toString());
    }

    /**
     *
     * @param {Color} otherColor
     * @returns {boolean}
     */
    equals(otherColor) {
        if(otherColor === null) {
            return false;
        }

        return otherColor.getRed() === this.#r &&
            otherColor.getGreen() === this.#g &&
            otherColor.getBlue() === this.#b;
    }

    cycle(frame, band) {
        const colors = [Color.OFF, 
                        Color.RED, 
                        Color.GREEN, 
                        Color.BLUE, 
                        Color.YELLOW, 
                        Color.WHITE];

        colors.forEach((color,i) => {
            if (this.equals(color)) {
                frame[band] = i < colors.length - 1 ? colors[i + 1] : colors[0];
                colors.splice(i, 1);
            }
        });
        
        if (colors.length === 6) {
            throw new Error("Unknown color: {r: " + this.#r + ", g: " + this.#g + ", b: " + this.#b + "}");
        }
    }

    static random() {
        // Generated random integer between 0 and 3
        let r = Math.floor(Math.random() * 5);
        let red = r === 0 ? 255 : 0;
        let green = r === 1 ? 255 : 0;
        let blue = r === 2 ? 255 : 0;
        let yellow = r === 3;

        if (yellow)
            return new Color(255, 255, 0);
        else
            return new Color(red, green, blue);
    }
}

class AnimationFrame {
    bandColor1 = new Color(0, 0, 0);
    bandColor2 = new Color(0, 0, 0);
    bandColor3 = new Color(0, 0, 0);
    bandColor4 = new Color(0, 0, 0);
    bandColor5 = new Color(0, 0, 0);

    constructor(bandColor1, bandColor2, bandColor3, bandColor4, bandColor5) {
        if (bandColor1) {
            this.bandColor1 = bandColor1;
        }

        if (bandColor2) {
            this.bandColor2 = bandColor2;
        }

        if (bandColor3) {
            this.bandColor3 = bandColor3;
        }

        if (bandColor4) {
            this.bandColor4 = bandColor4;
        }

        if (bandColor5) {
            this.bandColor5 = bandColor5;
        }
    }

    fromJson(str) {
        let frame = JSON.parse(str);
        for (let i = 1; i < 5; i++) {
            this[`bandColor${i + 1}`] = new Color(frame[i][0], frame[i][1], frame[i][2]);
        }
    }

    fromObject(obj) {
        for (let i = 1; i < 5; i++) {
            this[`bandColor${i + 1}`] = new Color(obj[(i)][0], obj[(i)][1], obj[(i)][2]);
        }
    }

    getBandColor(band) {
        switch (band) {
            case 1:
                return this.bandColor1;
            case 2:
                return this.bandColor2;
            case 3:
                return this.bandColor3;
            case 4:
                return this.bandColor4;
            case 5:
                return this.bandColor5;
            default:
                throw new Error(`Invalid band number: ${band}`);
        }
    }

    toString() {
        return `\t[${this.bandColor1.r}, ${this.bandColor1.g}, ${this.bandColor1.b}],\n` +
            `\t[${this.bandColor2.r}, ${this.bandColor2.g}, ${this.bandColor2.b}],\n` +
            `\t[${this.bandColor3.r}, ${this.bandColor3.g}, ${this.bandColor3.b}],\n` +
            `\t[${this.bandColor4.r}, ${this.bandColor4.g}, ${this.bandColor4.b}],\n` +
            `\t[${this.bandColor5.r}, ${this.bandColor5.g}, ${this.bandColor5.b}]`;
    }

    /**
     *
     * @param {int} id
     * @param {Color} bandColor
     */
    setBandActive(id, bandColor) {
        let bandElem = '#band' + id;
        $(bandElem).css({fill: bandColor.toString()});
        $(bandElem + "Text").text(bandColor.getName());
    }

    setActive() {
        this.setBandActive(1, this.bandColor1);
        this.setBandActive(2, this.bandColor2);
        this.setBandActive(3, this.bandColor3);
        this.setBandActive(4, this.bandColor4);
        this.setBandActive(5, this.bandColor5);
    }

    /**
     *
     * @param {AnimationFrame} frame
     */
    fromAnimationFrame(frame) {
        this.bandColor1 = new Color(frame.bandColor1.r, frame.bandColor1.g, frame.bandColor1.b);
        this.bandColor2 = new Color(frame.bandColor2.r, frame.bandColor2.g, frame.bandColor2.b);
        this.bandColor3 = new Color(frame.bandColor3.r, frame.bandColor3.g, frame.bandColor3.b);
        this.bandColor4 = new Color(frame.bandColor4.r, frame.bandColor4.g, frame.bandColor4.b);
        this.bandColor5 = new Color(frame.bandColor5.r, frame.bandColor5.g, frame.bandColor5.b);

    }
}

class Animation {
    /**
     * Private frames variable
     * @type {[AnimationFrame]}
     */
    frames = [AnimationFrame];

    constructor() {

    }

    /**
     * Get frame count
     */
    getFrameCount() {
        return this.frames.length;
    }

    /**
     * Add frame
     * @param {AnimationFrame} frame
     */
    addFrame(frame) {
        this.frames.push(frame);
    }

    toString() {
    }

    fromJson(json) {
        let jsonObject = JSON.parse(json);
        this.frames = [];
        for (let i = 0; i < jsonObject.length; i++) {
            let frame = new AnimationFrame();
            frame.fromObject(jsonObject[i]);
            this.frames.push(frame);
        }
    }

    getFrame(number) {
        if (number > this.frames.length)
            throw new Error(`Frame number ${number} is out of range (Only ${this.frames.length} frames)`);

        return this.frames[number];
    }

    /**
     *
     * @param {int} number
     * @param {Color} bandColor1
     * @param {Color} bandColor2
     * @param {Color} bandColor3
     * @param {Color} bandColor4
     * @param {Color} bandColor5
     */
    setFrameColor(number, bandColor1, bandColor2, bandColor3, bandColor4, bandColor5) {
        if (number > this.frames.length)
            throw new Error(`Frame number ${number} is out of range (Only ${this.frames.length} frames)`);
        if (bandColor2 === undefined)
            bandColor2 = new Color(0, 0, 0);
        if (bandColor3 === undefined)
            bandColor3 = new Color(0, 0, 0);
        if (bandColor4 === undefined)
            bandColor4 = new Color(0, 0, 0);
        if (bandColor5 === undefined)
            bandColor5 = new Color(0, 0, 0);

        this.frames[number].bandColor1 = new Color(bandColor1.r, bandColor1.g, bandColor1.b);
        this.frames[number].bandColor2 = new Color(bandColor2.r, bandColor2.g, bandColor2.b);
        this.frames[number].bandColor3 = new Color(bandColor3.r, bandColor3.g, bandColor3.b);
        this.frames[number].bandColor4 = new Color(bandColor4.r, bandColor4.g, bandColor4.b);
        this.frames[number].bandColor5 = new Color(bandColor5.r, bandColor5.g, bandColor5.b);

        this.frames[number].setActive();
    }

    toJson() {
        let result = "";
        for (let i = 1; i < this.frames.length; i++) {
            result += "[";
            result += "\n" + this.frames[i].toString();
            result += "\n]";
            if (i < this.frames.length - 1) {
                result += ",";
            }
        }
        return `[${result}]`;
    }

    removeFrame(currentFrame) {
        this.frames.splice(currentFrame, 1);
    }
}

anim = new Animation();
anim.addFrame(new AnimationFrame(
    bandColor1 = Color.RED,
    bandColor2 = Color.GREEN,
    bandColor3 = Color.BLUE,
    bandColor4 = Color.YELLOW,
    bandColor5 = Color.OFF
));
anim.addFrame(new AnimationFrame(
    bandColor1 = Color.OFF,
    bandColor2 = Color.YELLOW,
    bandColor3 = Color.BLUE,
    bandColor4 = Color.GREEN,
    bandColor5 = Color.RED,
));


$(document).ready(function () {
    let frameSelectDropdown = $("#frameSelect");
    let currentFrameText = $('#currentFrame');

    anim.frames[1].setActive();
    $('#totalFrames').text(anim.getFrameCount() - 1);
    currentFrameText.text(1);
    $('#totalTime').text((anim.getFrameCount() - 1) * 0.5);

    // Populate the animation frame dropdown
    for (let i = 1; i < anim.getFrameCount(); i++) {
        $('#frameSelect').append($('<option>', {
            value: i,
            text: "Frame " + i
        }));
    }

    // Bind change event to the animation frame dropdown
    frameSelectDropdown.change(function () {
        let frame = anim.getFrame($(this).val());
        frame.setActive();
        currentFrameText.text($(this).val());
    });

    // Bind click event to the next frame button
    $('#nextFrame').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());
        // check if the current frame is the last frame
        if (currentFrame === anim.getFrameCount() - 1) {
            return
        }

        currentFrame++;

        let frame = anim.getFrame(currentFrame);
        frame.setActive();
        frameSelectDropdown.val(currentFrame);
        currentFrameText.text(currentFrame);
    });

    // Bind click event to the previous frame button
    $('#prevFrame').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        // check if the current frame is the first frame
        if (currentFrame === 1) {
            return
        }

        currentFrame--;

        let frame = anim.getFrame(currentFrame);
        frame.setActive();
        frameSelectDropdown.val(currentFrame);
        currentFrameText.text(currentFrame);
    });

    // Bind click event to the last frame button
    $('#lastFrame').click(function () {
        let frame = anim.getFrame(anim.getFrameCount() - 1);
        frame.setActive();
        frameSelectDropdown.val(anim.getFrameCount() - 1);
        currentFrameText.text(anim.getFrameCount() - 1);
    });

    // Bind click event to the first frame button
    $('#firstFrame').click(function () {
        let frame = anim.getFrame(1);
        frame.setActive();
        frameSelectDropdown.val(1);
        currentFrameText.text(1);
    });

    // Bind click event on play button
    $('#play').click(function () {
        // Disable all other buttons
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
        $('#fillRandom').attr('disabled', true);
        $('#fillRed').attr('disabled', true);
        $('#fillGreen').attr('disabled', true);
        $('#fillBlue').attr('disabled', true);
        $('#fillYellow').attr('disabled', true);
        $('#fillClear').attr('disabled', true);

        let selected = 0;
        frameSelectDropdown.val(selected + 1);
        selected++;
        anim.getFrame(selected).setActive();

        playInterval = setInterval(function () {
            if (selected === anim.getFrameCount() - 1) {
                selected = 0;
                //clearInterval(interval);
            }

            frameSelectDropdown.val(selected + 1);
            selected++;
            $('#currentFrame').text(selected);
            anim.getFrame(selected).setActive();
        }, 500);
    });

    // Bind click event on stop button
    $('#stop').click(function () {
        // Enable all other buttons
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
        $('#fillRandom').attr('disabled', false);
        $('#fillRed').attr('disabled', false);
        $('#fillGreen').attr('disabled', false);
        $('#fillBlue').attr('disabled', false);
        $('#fillYellow').attr('disabled', false);
        $('#fillClear').attr('disabled', false);

        clearInterval(playInterval);
    });

    // Bind click event on remove last frame button
    $('#removeFrame').click(function () {
        // check if its the last frame
        if (anim.getFrameCount() - 1 === 1) {
            return
        }

        anim.removeFrame(anim.getFrameCount() - 1);
        anim.getFrame(1).setActive();
        frameSelectDropdown.val(1);
        frameSelectDropdown.children().last().remove();
        currentFrameText.text(1);

        $('#totalFrames').text(anim.getFrameCount());
        $('#totalTime').text((anim.getFrameCount() - 1) * 0.5);

        if (anim.getFrameCount() - 1 === 1) {
            $('#removeFrame').attr('disabled', true);
        }
    });

    // Bind click event on add frame button
    $('#addFrame').click(function () {
        anim.addFrame(new AnimationFrame());
        anim.getFrame(anim.getFrameCount() - 1).setActive();

        frameSelectDropdown.append('<option value="' + (anim.getFrameCount() - 1) + '">Frame ' + (anim.getFrameCount() - 1) + '</option>');
        frameSelectDropdown.val(anim.getFrameCount() - 1);
        $('#totalFrames').text(anim.getFrameCount() - 1);
        $('#totalTime').text((anim.getFrameCount() - 1) * 0.5);
        $('#removeFrame').attr('disabled', false);
    });

    // Bind click event on duplicate frame button
    $('#dupeFrame').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        let newFrame = new AnimationFrame();
        newFrame.fromAnimationFrame(anim.getFrame(currentFrame));
        anim.addFrame(newFrame);
        anim.getFrame(anim.getFrameCount() - 1).setActive();

        frameSelectDropdown.append('<option value="' + (anim.getFrameCount() - 1) + '">Frame ' + (anim.getFrameCount() - 1) + '</option>');
        frameSelectDropdown.val(anim.getFrameCount() - 1);
        $('#totalFrames').text(anim.getFrameCount() - 1);
        $('#totalTime').text((anim.getFrameCount() - 1) * 0.5);
        $('#removeFrame').attr('disabled', false);
    });

    // Bind click event on save button
    $('#save').click(function () {
        $.ajax({
            url: '/save',
            type: 'POST',
            data: anim.toJson(),
            contentType: 'application/json',
            success: function (data) {
                console.log(data);
            }
        });
    });

    // Bind click event on export button
    $('#export').click(function () {
        $("body").append("<div id='exportDialog' style='width:100%; height:100%;position:absolute; top:0;left:0; background:rgba(0, 0, 0, 0.9);'>" +
            "<textarea id='exportData' readonly style='margin: 50px auto;display: block;width: 50%;height:50%;'></textarea>" +
            "<button id='closeExportDialog' style='margin: 50px auto;display: block;'>Close</button>" +
            "</div>");
        let exportDataElem = $('#exportData');

        exportDataElem.click(function () {
            $(this).select();
        });
        $('#closeExportDialog').click(function () {
            $('#exportDialog').remove();
        });

        exportDataElem.val(anim.toJson());
    });

    // Bind click event on fill random button
    $('#fillRandom').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        anim.setFrameColor(currentFrame, Color.random(), Color.random(), Color.random(), Color.random(), Color.random());
    });

    // Bind click event on fill red button
    $('#fillRed').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        anim.setFrameColor(currentFrame, Color.RED, Color.RED, Color.RED, Color.RED, Color.RED);
    });

    // Bind click event on fill green button
    $('#fillGreen').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        anim.setFrameColor(currentFrame, Color.GREEN, Color.GREEN, Color.GREEN, Color.GREEN, Color.GREEN);
    });

    // Bind click event on fill blue button
    $('#fillBlue').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        anim.setFrameColor(currentFrame, Color.BLUE, Color.BLUE, Color.BLUE, Color.BLUE, Color.BLUE);
    });

    // Bind click event on fill yellow button
    $('#fillYellow').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        anim.setFrameColor(currentFrame, Color.YELLOW, Color.YELLOW, Color.YELLOW, Color.YELLOW, Color.YELLOW);
    });

    // Bind click event on fill clear button
    $('#fillClear').click(function () {
        let currentFrame = parseInt(frameSelectDropdown.val());

        anim.setFrameColor(currentFrame, Color.OFF, Color.OFF, Color.OFF, Color.OFF, Color.OFF);
    });

    // Bind click event on band buttons
    for (let i = 1; i < 6; i++) {
        $(`#band${i}Container`).click(function () {
            const currentFrame = parseInt(frameSelectDropdown.val());
            const frame = anim.getFrame(currentFrame);
            frame[`bandColor${i}`].cycle(frame, `bandColor${i}`);
            frame.setActive();
        });
    }
});