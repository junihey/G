{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 1,
            "revision": 2,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [ 33.0, 81.0, 1153.0, 675.0 ],
        "boxes": [
            {
                "box": {
                    "id": "obj-4",
                    "linecount": 4,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 571.0, 18.0, 169.0, 60.0 ],
                    "text": "grain size (K): \"too small a grain size results in metallic AM side-bands, and too large results in audible repeats\""
                }
            },
            {
                "box": {
                    "attr": "timerate",
                    "id": "obj-15",
                    "maxclass": "attrui",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 251.5, 43.0, 150.0, 22.0 ]
                }
            },
            {
                "box": {
                    "attr": "pitchrate",
                    "id": "obj-13",
                    "maxclass": "attrui",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 90.0, 43.0, 150.0, 22.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-55",
                    "lastchannelcount": 0,
                    "maxclass": "live.gain~",
                    "numinlets": 2,
                    "numoutlets": 5,
                    "orientation": 1,
                    "outlettype": [ "signal", "signal", "", "float", "list" ],
                    "parameter_enable": 1,
                    "patching_rect": [ 19.0, 590.0, 136.0, 47.0 ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_initial": [ -70.0 ],
                            "parameter_initial_enable": 1,
                            "parameter_longname": "live.gain~",
                            "parameter_mmax": 6.0,
                            "parameter_mmin": -70.0,
                            "parameter_modmode": 3,
                            "parameter_shortname": "live.gain~",
                            "parameter_type": 0,
                            "parameter_unitstyle": 4
                        }
                    },
                    "varname": "live.gain~"
                }
            },
            {
                "box": {
                    "id": "obj-16",
                    "maxclass": "ezdac~",
                    "numinlets": 2,
                    "numoutlets": 0,
                    "patching_rect": [ 19.0, 644.0, 45.0, 45.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 19.0, 11.0, 24.0, 24.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-5",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 19.0, 37.0, 39.0, 22.0 ],
                    "text": "click~"
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "float", "bang" ],
                    "patching_rect": [ 612.0, 602.5, 116.0, 22.0 ],
                    "text": "buffer~ buf jongly.aif"
                }
            },
            {
                "box": {
                    "code": "// Adapted from Dialectric Studios \"Keyframe Audio via Extrema Sampling\"\r\n// Demo: https://www.youtube.com/watch?v=hQ3FgaHN-ig\r\n// Preprint: https://communiteq-eu5.nbg1.your-objectstorage.com/uploads/db8181/original/4X/4/4/f/44f4593d1c01733d6089eb434fc4f8bc6582ed4b.pdf\r\n\r\nh(t) { // coefficients for Cubic Hermite interpolation\r\n    t2 = t * t;\r\n    t3 = t2 * t;\r\n    \r\n    h00 = 2 * t3 - 3 * t2 + 1;\r\n    h10 = -2 * t3 + 3 * t2 ;\r\n    \r\n    return h00, h10;\r\n}\r\n\r\nB(x, pos) { // B-spline interpolation\r\n    n = floor(pos);\r\n    t = pos - floor(pos);\r\n    t2 = t * t;\r\n    t3 = t2 * t;\r\n    \r\n    b0 = -1 * t3 + 3 * t2 - 3 * t + 1;\r\n    b1 = 3 * t3 - 6 * t2 + 4;\r\n    b2 = -3 * t3 + 3 * t2 + 3 * t + 1;\r\n    b3 = t3;\r\n    \r\n    val = (x.peek(n-1) * b0 + x.peek(n) * b1 + x.peek(n+1) * b2 + x.peek(n+2) * b3) / 6;\r\n    \r\n    return val;\r\n}\r\n\r\nanalyze(x, y, epsilon) { // compression (algorithm 1)\r\n    Data deltas(30 * 48000);\r\n    dprev = 0;\r\n    vprev = x.peek(0);\r\n    M = 1; // = dim(y)\r\n    N = dim(x);\r\n    \r\n    y.poke(0, 0, 0);\r\n    y.poke(x.peek(0), 0, 1);\r\n    \r\n    for (i = 1; i < N-1; i += 1) {\r\n        deltas.poke((x.peek(i+1) - x.peek(i-1)) / 2, i); \r\n        \r\n        \r\n        if (sign(deltas.peek(i)) != sign(dprev)) {\r\n            if (abs(x.peek(i) - vprev) > epsilon) {\r\n                a = abs(deltas.peek(i-1)) / (abs(deltas.peek(i-1)) + abs(deltas.peek(i)));\r\n                n_m = i - 1 + a;\r\n                v_m = B(x, n_m);\r\n                \r\n                y.poke(n_m, M, 0);\r\n                y.poke(v_m, M, 1);\r\n                M += 1;\r\n                vprev = v_m;\r\n            }\r\n        }\r\n        dprev = deltas.peek(i);\r\n    }\r\n    y.poke(N-1, M, 0);\r\n    y.poke(x.peek(N-1), M, 1);\r\n    M += 1;\r\n    \r\n    return M;\r\n}\r\n\r\n// x: sparse buffer\r\n// n: playhead\r\n// M: keyframe buffer size\r\n// m: window start\r\nfind_window(x, n, M, m = 0) {\r\n    upper = M - 2;\r\n    n_m = x.peek(m + 1, 0);\r\n    while (n > n_m && m < upper) {\r\n        m += 1;\r\n        n_m = x.peek(m + 1, 0);\r\n    }\r\n    return m;\r\n}\r\n\r\n// x: sparse buffer\r\n// n: playhead\r\n// M: keyframe buffer size\r\n// m: window start\r\ninterpolate(x, n, M, m = 0) {\r\n    m = find_window(x, n, M, m = m);\r\n    n_m = x.peek(m, 0);\r\n    n_mpp = x.peek(m + 1, 0);\r\n    v_m = x.peek(m, 1);\r\n    v_mpp = x.peek(m + 1, 1);\r\n    t = (n - n_m) / (n_mpp - n_m);\r\n    t = clip(t, 0, 1);\r\n    h00, h10 = h(t);\r\n    y = v_m * h00 + v_mpp * h10;\r\n    \r\n    return y, m;\r\n}\r\n\r\nData keyframes(30 * 48000, 2);\r\nData processed(30 * 48000);\r\nBuffer buf(\"buf\");\r\nHistory K(150); // keyframe distance threshold for splicing\r\nHistory ref, play, temp;\r\nHistory ref_m, play_m, temp_m; // sparse indices\r\nHistory t_temp, temprate;\r\nHistory splicing(0);\r\nHistory M; // number of keyframes\r\nParam timerate(1, min=0), pitchrate(1, min = .2);\r\nParam epsilon(.001);\r\nParam loop(0);\r\n\r\nN = dim(buf); // input sample size\r\n\r\nif (elapsed == 0 || in1) {\r\n    M = analyze(buf, keyframes, epsilon);\r\n}\r\n\r\nif(in1) {\r\n    play = 0;\r\n    play_m = 0;\r\n    ref = 0; \r\n    ref_m = 0;\r\n    splicing = 0;\r\n}\r\n\r\nref_m = find_window(keyframes, ref, M, m = ref_m);\r\nplay_m = find_window(keyframes, play, M, m = play_m);\r\nd = abs(play_m - ref_m);\r\n\r\n\r\nif (!splicing && d > K) {\r\n    temp, temp_m = ref, ref_m;\r\n    L = 0;\r\n    for (i = 0; i < K; i += 1) {\r\n        n_m = keyframes.peek(ref_m + i, 0);\r\n        n_mpp = keyframes.peek(ref_m + i + 1, 0);\r\n        L += n_mpp - n_m;\r\n    }\r\n    t_temp = 0;\r\n    temprate = 1 / L;\r\n    splicing = 1;\r\n}\r\n\r\nif (splicing && t_temp <= 1) {\r\n    y_play, play_m = interpolate(keyframes, play, M, m = play_m);\r\n    y_temp, temp_m = interpolate(keyframes, temp, M, m = temp_m);\r\n    y = y_temp * t_temp + y_play * (1 - t_temp);\r\n    play += pitchrate;\r\n    temp += pitchrate;\r\n    t_temp += temprate * pitchrate;\r\n    ref += timerate;\r\n    out1 = dcblock(y);\r\n} else if (splicing && t_temp > 1) {\r\n    play = temp;\r\n    play_m = temp_m;\r\n    splicing = 0;\r\n}\r\n\r\nif (!splicing) {\r\n    y, play_m = interpolate(keyframes, play, M, m = play_m);\r\n    play += pitchrate;\r\n    ref += timerate;\r\n    out1 = dcblock(y);\r\n}\r\n\r\nif (ref > N && loop) {\r\n    play = 0;\r\n    play_m = 0;\r\n    ref = 0; \r\n    ref_m = 0;\r\n    splicing = 0;\r\n}",
                    "fontface": 0,
                    "fontname": "<Monospaced>",
                    "fontsize": 12.0,
                    "id": "obj-1",
                    "maxclass": "gen.codebox~",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 19.0, 76.0, 728.0, 508.0 ]
                }
            },
            {
                "box": {
                    "attr": "K",
                    "id": "obj-21",
                    "maxclass": "attrui",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 413.0, 43.0, 150.0, 22.0 ]
                }
            },
            {
                "box": {
                    "attr": "loop",
                    "displaymode": 8,
                    "id": "obj-12",
                    "maxclass": "attrui",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 90.0, 12.0, 150.0, 22.0 ]
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "obj-55", 0 ],
                    "source": [ "obj-1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "midpoints": [ 99.5, 36.0, 69.0, 36.0, 69.0, 69.0, 28.5, 69.0 ],
                    "source": [ "obj-12", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "midpoints": [ 99.5, 70.5, 28.5, 70.5 ],
                    "source": [ "obj-13", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "midpoints": [ 261.0, 70.5, 28.5, 70.5 ],
                    "source": [ "obj-15", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "midpoints": [ 422.5, 70.5, 28.5, 70.5 ],
                    "source": [ "obj-21", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "source": [ "obj-5", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-16", 1 ],
                    "order": 0,
                    "source": [ "obj-55", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-16", 0 ],
                    "order": 1,
                    "source": [ "obj-55", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 0 ],
                    "source": [ "obj-7", 0 ]
                }
            }
        ],
        "parameters": {
            "obj-55": [ "live.gain~", "live.gain~", 0 ],
            "inherited_shortname": 1
        },
        "autosave": 0
    }
}