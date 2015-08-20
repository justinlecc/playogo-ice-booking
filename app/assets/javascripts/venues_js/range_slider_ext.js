/*
 * jQuery UI Slider Range extension 1.1 (25 Oct 2011)
 *
 * This extension is based code provided by
 * jQuery UI Slider version 1.8.13
 * it may happen tht it won't work with newer versions
 *
 * Copyright (c) 2011 Robert Koritnik
 * Licensed under the terms of the MIT and GPL-2.0 license
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.opensource.org/licenses/GPL-2.0
 *
 * from http://erraticdev.blogspot.ca/2011/08/advanced-jquery-ui-range-slider.html
 */
 
(function($) {
    if ($.ui.slider)
    {
        // add minimum range length option
        $.extend($.ui.slider.prototype.options, {
            minRangeSize: 2,
            maxRangeSize: 100,
            autoShift: true,
            lowMax: 100,
            topMin: 0
        });
 
        $.extend($.ui.slider.prototype, {
            _slide: function(event, index, newVal) {
                var otherVal,
                newValues,
                allowed,
                factor;

                if (this.options.values && this.options.values.length)
                {
                    otherVal = this.values(index ? 0 : 1);
                    factor = index === 0 ? 1 : -1;
 
                    if (this.options.values.length === 2 && this.options.range === true)
                    {
                        // lower bound max
                        if (index === 0 && newVal > this.options.lowMax)
                        {
                            newVal = this.options.lowMax;
                        }
 
                        // upper bound min
                        if (index === 1 && newVal < this.options.topMin)
                        {
                            newVal = this.options.topMin;
                        }
 
                        // minimum range requirements
                        if ((otherVal - newVal) * factor < this.options.minRangeSize)
                        {
                            if (this.options.autoShift === true)
                            {
                                otherVal = newVal + this.options.minRangeSize * factor;
                            }
                            else
                            {
                                newVal = otherVal - this.options.minRangeSize * factor;
                            }
                        }
 
                        // maximum range requirements
                        if ((otherVal - newVal) * factor > this.options.maxRangeSize)
                        {
                            if (this.options.autoShift === true)
                            {
                                otherVal = newVal + this.options.maxRangeSize * factor;
                            }
                            else
                            {
                                newVal = otherVal - this.options.maxRangeSize * factor;
                            }
                        }
                    }
 
                    if (newVal !== this.values(index))
                    {
                        newValues = this.values();
                        newValues[index] = newVal;
                        newValues[index ? 0 : 1] = otherVal;
                        
                        // A slide can be canceled by returning false from the slide callback
                        allowed = this._trigger("slide", event, {
                            handle: this.handles[index],
                            value: newVal,
                            values: newValues
                        });
                        if (allowed !== false)
                        {
                            this.values(index, newVal, true);
                            this.values(index ? 0 : 1, otherVal, true);
                        }
                    }
                }
                else
                {
                    if (newVal !== this.value())
                    {
                        // A slide can be canceled by returning false from the slide callback
                        allowed = this._trigger("slide", event, {
                            handle: this.handles[index],
                            value: newVal
                        });
                        if (allowed !== false)
                        {
                            this.value(newVal);
                        }
                    }
                }
            }
        });
    }
})(jQuery);
