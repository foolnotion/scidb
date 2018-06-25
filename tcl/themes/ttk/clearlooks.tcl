# This software is copyrighted by the Regents of the University of California, Sun Microsystems, Inc., Scriptics
# Corporation, and other parties.
namespace eval ttk::theme::clearlooks {

    package provide ttk::theme::clearlooks 0.2

    variable colors

    array set colors {
        -frame          "#efebe7"
        -lighter        "#f5f3f0"
        -dark           "#cfcdc8"
        -darker         "#9e9a9e"
        -darkest        "#d4cfca"
        -selectbg       "#7c99ad"
        -selectfg       "#ffffff"
        -disabledfg     "#b5b3ac"
        -entryfocus     "#6f9dc6"
        -tabbg          "#c9c1bc"
        -tabborder      "#b5aca7"
        -troughcolor    "#d7cbbe"
        -troughborder   "#ae9e8e"
        -checklight     "#f5f3f0"
    }

    array set I [list \
        toolbutton-n [image create photo -data { \
            R0lGODdhGAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n55ySe5yKe97f1pSCc97b1tbT
            zs7LxpyShJyOhJyKhIR5c97bzox9c4x5c4R9a4R5a4R1a3t1a4SCc+fr3ufn3ufj3uff3ufb3v//
            /3t1Y/f79/f39/fz9/fv9+/37+/z7+/v7+/r75SKe5SGe5SCe4yGc4yCc+/r3u/n3u/j3ufj1uff
            1ufb1v/39wAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sDDI0MsGo/HhzAT
            ajqfUGjmoQmRSCOsjWTbbkdbLnhUEzFJARLgmg6kr4BA6R2oZTChU0kg18//AQKCfwI1GBMhJoKC
            JiiLgigDAyiKAiiGeCkFA5spKQOfnZqgmwM1FhchKQYErK6rBqsprQSrBDUVFSEGBwa8vK0HKq69
            rgY1FxshB8y8zL3Pz8PPuLrR19jXNS8vy88c1+DZBzUtLcswCDAHCBzt7Ozr8e01DC4hCAjs4Pr5
            4O4A+5VjESKdu3zv+qlbuLCGC4IIYnSQGJBDxYgAa7BYEaJDPo8IPE4MGTEGyXw1VnCcKFKiSZci
            J0rskFJBRw8yPODU2WGnU4yeOHvKqKFAQogPM2YgVcp06QcPST88rSEhQYgFIGjQWKCVKwisW7Nm
            xVojQoQQDdI2qLGWbVq3a99SKOsAQo27ePPq1QvBwYG6EAILHkx4sN8gADs=
        }] \
        arrowleft-d [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1rWyrefr3ufn3ufj
            3uff3sa2rf////f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFbyAkjmQJRWiqpmIUTIEUAC8wTVsr7NPuU4LcqTCgUAaFRbEojAwqlYFhsXBGmweDZUqN
            HAgGLANB7R7OzTHiUo4g3s1LI9FgVxv4Jsbh2DuqGHtNGQ8OD4QOEQ+HTRoKDwoakJCSTRuXmJmX
            JpwjIQA7
        }] \
        scale-hn [image create photo -data { \
            R0lGODlhHgAPANUAAO/r5+/n5+/j55ySe5yKe97f1t7b1t7X1t7T1tbTzs7LxpyShJyKhN7fzt7b
            zt7Xzt7Tzox9c4x5c4R9a4R5a4R1a/8AAOfr3ufn3ufj3uff3ufb3sa2rf/////7/5SKe5SGe4yG
            c4yCc+/r3u/n3u/j3ufj1uff1ufb1ufX1gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABYALAAAAAAeAA8AAAb6QIui
            Qiwaj8ijQljpOJ/QqDRaGXYugQAggB1dtlssFjDKlsWQCqUTwGDa2bec5IbL7aT0GpMpYQR8fiUZ
            GCV+gIdug38QFBMdGZGSkYMcHhmWmJeTkhASER0mGhkaoqaaGpapHqOlrhoQESIdGicnGgUatbqW
            Bb29uLoFJwUQIiEdBSjDy8TDvx6+HicbtgUbKCcQISAdDQYoBsrKy5YolgboBg3h38UgBB0pDgb0
            9Qb39PP3KQbz/fggfIjn4ICDBwYNIkRYkKHCBw4dQGAwoANEBBAzYoQI4UHHixk/QoAwIMGCkShT
            qly5ckECCyYXyJxJs6ZNmi+DAAA7
        }] \
        radio-nc [image create photo -data { \
            R0lGODlhEQARANUAAAAAAK2ejPfv7+/r5+/n597b1t7X1r2upXt5e3Nxc1pZWkpJSt7Xzsa+tca6
            tf8AAJyanJSWlIyOjOfj3uff3sa2rZyWlLWqnP/////7/62ilPf39/fz9zk8OTk4Oefj5yksKb22
            rSEgIf/3987DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAA8ALAAAAAARABEAAAaEwIdw
            SCwaj8gho6IJaCqMpONCYkwmhoPj6AhRBiNMBoNpbImMy0Rg8QA8EPIhOqyQPpFFQpLoxAsVRBoG
            HB4JCAodbxgbGkQBBCMAEokgAABkAYIEGIYdlouNRBUFGBCKlyJ/gUoHZBBucHJ0Qw4NZLhkZlwH
            BRuMBVpJS01PtEnIyUZBADs=
        }] \
        tree-d [image create photo -data { \
            R0lGODdhGAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597j1t7f1ufr3ufn3ufj
            3uff3ufb3sa2rf////f39/fz9/fv9+/37+/z7+/v7+/r7+/r3u/n3u/j3u/f3ufj1uff1ufb1gAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sCIcEgsGomSpHLJ
            bEqEkskkMAVIrZSpdAIIUAIg6Jcy9gbO5TIYaqEIvO10QEAfC8IRSYVOr1z4dBcDAxd7Ahd4EoeE
            A4uCgoeQggOJAwUDGJaaBZmZmIOXiQYDBqMGGASjqamkBqkGiRmuBgepsqUHB6WpB7KJvAS6wLTE
            uboHiQcIxszNy8YIyRoI0wgM1soI1MvbDInaG9YNCOHWG9foCOOJDRvjCRsJDQ3y8OPt8tFQ8vPz
            Dg0c5gUc6K8BOwcDOSB0sFAhQoAKEzGc6MCDgwcVGXbIyNBDIg8PMIa8CFJkyQcWHyR68EEBS5cg
            P6CU+aFlyA+JFkCouYDnIwcIOj8E3akzEYieII5CACEU54KjUKFCSUq1qtWreI5o1RoEADs=
        }] \
        arrowright-n [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1oR1a3t1a+fr3ufn
            3ufj3uff3v///3t1Y/f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1hAQEAAAAAAAACwAAAAA
            DwAPAAAFgaC0jGRJMkukruy6MFFABVMAyABFcWIk/JSfsCLgvCKFQaXSSSqVHFRkYLEMOh2D1cpL
            HQwXA7ZzORAMRtihgTiMO4d4NMVGYMaIPMIoiWAcCQ5YDn8ODkYpGQ8PGR2MjIpRfRoQDxCUixCX
            cxEbChAKG6CgomkRHKipqqgiJq4kIQA7
        }] \
        check-pu [image create photo -data { \
            R0lGODlhEQARAJEAAK2ejNbPztbLxv8AACH5BAEAAAMALAAAAAARABEAAAIxnI+py+APHwKi2ivA
            FKH7rx3URwahMZbeOaSqub0d66o0J98yLOKvnptEhiyG8ZgoAAA7
        }] \
        scaletrough-v [image create photo -data { \
            R0lGODlhDwAeAJEAANbLvca2rf8AAK2ejCH5BAEAAAIALAAAAAAPAB4AAAJAlD2ZxzcBR2sPADld
            sDiLennIFopgl53iR6KTarYr7NGpHHMzXvO3niv1gEPhz/jyJYlHF0X5ZC6RUSpDsWAUAAA7
        }] \
        scale-va [image create photo -data { \
            R0lGODlhDwAeANUAAPfz7/fv7/fr7+/z5+/v5+/r5+/n5+/j55ySe97f1t7b1t7X1tbXztbTzs7L
            xpyShJyOhJyKhIR5c97fzt7bzt7Xzt7Tzox9c4x5c4R9a4R5a4R1a/8AAIyCe+fr3ufn3ufj3uff
            3ufb3sa2rf/////7/+/z7+/v7+/r75SOe5SKe5SGe5SCe4yGc4yCc+/n3u/j3ufj1uff1ufb1ufX
            1gAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABwALAAAAAAPAB4AAAb+QI5j
            QywaNw7hhsRsOknIpSkQAASmpoHVQiQFToNAWEzmLk+nAEGdbnM1JIKAQJfbBRYNJj6fowgFdAUW
            EhIkBYiBBSiJBBYZGYeJiR6JjxckHgYGBZqaBpoWGJgGH6CbpqcWF5imHy+lpaYvFi4uJC8fByO8
            vAcfH6u3IB8gJcfHMLq1wyDOxdDFFh0sJCAwMb281yC11SExIcjHIOEWLCskISEy6+3h7BYt6TIJ
            IdojMvUWK+ki+uNKiEggwoIKFSQSJJgxY2FDhTMMImQ4IYGChQpmXJRIgkLGjxRmhFRgIUUEEgto
            UFi5oCWFBRQsRIBAogKFCi1twsRZkmYszgo4gQq1AIHm0AoWgFpgYMECAppNkzZlSpVogwdRs2Z9
            0IDD1Qdgw4rtGgQAOw==
        }] \
        scale-vn [image create photo -data { \
            R0lGODlhDwAeANUAAO/r5+/n5+/j55ySe97j1t7f1t7b1t7X1t7T1tbXztbTzs7LxpyShJyOhJyK
            hIR5c97bzt7Xzt7Tzox9c4x5c4R9a4R5a4R1a/8AAIyCe+fr3ufn3ufj3uff3ufb3sa2rf/////7
            /5SOe5SKe5SGe5SCe4yGc4yCc+/n3u/j3ufj1uff1ufb1ufX1gAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABgALAAAAAAPAB4AAAb+QMzi
            QiwaLwvhBcRsOkHIJQAQmFo1UwkRVNUEvN+wdhkob8LlstYCOp9R7sBZYqG0BRs8Hj5/PEApGxuB
            HHgpeBIVFW2EgYGCHIkTbRwpHIODjhIUkxyen6CRE50dnh0qpxylEicnIKUdH7KyqRITrh0EHSG8
            vB2/rK4rwysFHcYFxhIZJa/Hs7IrHSuszcUrvbzXEiUkICwsBSwe4uLhEibeBuLQHwbrEiTeLAYs
            2SEsECwSIyMgEO9aGBBoAKABfv5aHIAAYaHDhQj/NTzQgmFFiCIcgDhwIAKECBE6hoQgwUEDECBD
            phR5QIKIkwgkREgQQWbKmg1OppTJU0IdAgkSBpwEStSn0Z8NFDAoyhQoAwUYlDKYSrUq1CAAOw==
        }] \
        check-pc [image create photo -data { \
            R0lGODlhEQARANUAAAAAAK2ejGNdWikkIdbPzs7Lxs7HxggIAFJVUkpNSkpJSkJBQtbPxtbLxnt5
            c3t1c6WenGtpY/8AAIyKjL26tZSSjJSOjMbDvYyKhDk4OSksKRAUEBAQEAgMCAgICIR9ewAEAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABIALAAAAAARABEAAAZpQIlw
            SCwaj8iAcslcEgONqHTaCDwbhKzWIEAQrEOoNmvILArfq+GSZSQ4lCxYCNV0PgQM4KGdS6ATByAV
            AxtoclcEDgAeABFjfmIECoxxfYkEFxsKY2lhWFkWEJ2RoJ2XYU2qfkitrkVBADs=
        }] \
        radio-pc [image create photo -data { \
            R0lGODlhEQARANUAAAAAAK2ejDk4MTEsKd7b1r2ypb2updbPzs7Lxs7Hxnt9e3t5e3Nxc1pZWsa+
            vUJFQtbPxtbLxnt5c8a+tca6tf8AAIyOjM6+tca6rbWqnLWmnK2ilMbDvTk8OSksKRgYGLWilM7H
            vc7DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABUALAAAAAARABEAAAaEwIpw
            SCwaj8ghAQMKgDCE5GVjoDgcFM3leMlMQpED5HAwbImEDSexGAAGCrImOsQURJIHw8IQxCkYRCAU
            CAMMCw0dbwcIIEQBIhEAFokeAABkAYIiB4YdlouNRBgUBwoClwAff4FKGmQKbnBydEMXBmS5ZGZc
            GoSMWWdHS01PtUnIyUZBADs=
        }] \
        check-ac [image create photo -data { \
            R0lGODlhEQARANUAAAAAAK2ejHN1c2tpa1pdWlJRUkpJSrW2tbWyta2ura2qrf8AAJyanJSWlJSS
            lISChP/////7//f39/fz9+/v7zk4Oefn5+fj5zEwMRgYGMbDxhAUEBAQEAgMCAgICAAEAP/39wAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAAsALAAAAAARABEAAAZowIVw
            SCwaj8iAcslcEgOgqHQKCjxBkKxWIhhArEOoNisxFCLf64SiJWwsWbAQWuEwIAqAQytfQBMeHwcY
            GRJ8VxANAB0AD2N9YhAEixePiBAUGQRjaWFYWQganJCfnIdhTal9SKytRUEAOw==
        }] \
        sbthumb-vn [image create photo -data { \
            R0lGODdhDwAUAMQAAN7f1u/j3nt1a+/r5+fn3vf37+/n5+fj3vfz7+/j5+ff3vfv7+/z7/fr73t1
            Y+/v7+/r7+fj1v/z9/f39+ff1oR1a/fz9+fb1u/z5////+/n3u/v5+fr3gAAAAAAAAAAACwAAAAA
            DwAUAAAFlKBTCWNViiJZZWzrtmZWINgyDJwWRNQVW4jFY8MxEA4KgG81YzwgBkPigFxmJhbGYjPQ
            EAJJ62w7iGoOPKuEZsNNFQpxkBv9HpS/4LN8rsbWWjdGYHgrWUINZV8KPXladEcRcTFjD4k5YI1M
            CAxcfFSThhYLbRx2hTIMj3VIoRkWQJ4aU2kxF7e4ubcmFSkCIrwCKiEAOw==
        }] \
        toolbutton-d [image create photo -data { \
            R0lGODdhGAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n597f1t7b1t7bzufr3ufn3ufj
            3uff3ufb3sa2rf////f79/f39/fz9/fv9+/37+/z7+/v7+/r7+/r3u/n3u/j3ufj1uff1ufb1v/3
            9wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sADKEIsGo9HkDAi
            aTqfUGhkKKFQJtcQJaTVTrTb72TIpAQoAOs5cLYCApV2gCy5VARwe3wfEPj3AnQWfn4WGIR+GAMD
            GIMCGHQZBQOTGRkDl5WSmJMDkQYEoKIZBgakGaEEpAR0BgelrwehBxqir6IGdAe7rruxvru1vrrA
            xcbAxLsMxcvHS0wHGwgbBwgM1tXV1NrWdAgI1cvg38vX5uN00tff2OPT7+/eHA3z5wz2CBzmdA3f
            /Qj96AHMx2HgN37zAM4ruDAgvXkN+Dno4GBixQYWO2CciLEDnQcePIAUSXLkAwchH5ykkwDChw8J
            XsaE0BKmS5ct6SjYqQBEGU+fO4H2DLpgiFEQSJMqXap0yjMkUJMcCAIAOw==
        }] \
        scale-ha [image create photo -data { \
            R0lGODlhHgAPANUAAPfv7/fr7+/z5+/v5+/r5+/n5+/j55ySe5yKe97f1t7b1t7X1tbTzs7LxpyS
            hJyKhN7bzt7Xzt7Tzox9c4x5c4R9a4R5a4R1a/8AAOfr3ufn3ufj3uff3sa2rf/////7/+/v75SK
            e5SGe4yGc4yCc+/r3u/n3u/j3ufj1uff1ufb1ufX1gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABgALAAAAAAeAA8AAAb3QEzj
            Qiwaj8hjQ3jxOJ/QqDR6GXoEAAAIgAUJtltsd6vlciUXiycwGLBB7Hi7DXIP6vIBWk3o+/+AgYAS
            FhUeGQWIBCUFjBkdHyWQBJCJBQSNiRIUEx4aBp+hJhoakCaQBqgao6MGJhITJB4btBsaGye0J5Cl
            H723GrnAEiQjsxwoHBwbyLSQG5Aoz8q0yhwSIyIeCSkcKQkc4OGQHJAp5t/e3AkSIggeKgoqCfHy
            8/X39vL09hIh7xBWQFAgUGBAggMRClSgYGBACBIeHPAQIcKCihgvVryo0WLGjRIOMHAgoaTJkyhT
            onTAAMNIBzBjypxJU2bLIAA7
        }] \
        button-a [image create photo -data { \
            R0lGODdhHAAcANUAAPf37/fz7/fv7+/z5+/v5+/r5+/n55ySe5yOe5yKe5yGe9bTzs7LxpyShJyO
            hIR9c5yKhIR5c4R1c5R9e4x9c4x5c4R9a4R5a4R1a3t1a+fr3ufn3ufj3uff3v/////7///3//f/
            9/f79/f39/fz9+/37+/z7+/v7+/r75SOe5SKe5SGe5SCe4yKc4yGc4yCc+/n3u/j3ufj1ufb1v/7
            9//39wAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAHAAcAAAG/sACA0MsGo/IIkOI
            8Tif0Kj0iWFkptisZ0b0fEKfjxfsCXnHX7FX/OFeyh8RGJyex2lp/Hx2kXhAIjQ0IoCCgYMggIWE
            IoF8b401IiORIpKSjZSWlJczERYeIwA1IzUAoqgjqqSqo60jMxUVHqcAtSMkp7m5ogC5tSSwD6C7
            AAG7JbYBAba5x76/MxQUHiQlxwEl1iTb2tfH39oB0i8eJssB5+jp6CTq7efS1OzqJu7q7sv59eMT
            5QLLBJh4JzCdwIImEAqY8YKFuQADAgAUmDAhPYnnTAwAOIOFQ4oDE27UeHDkSAEUZ7hY4WGjAJcV
            Txw0IdOlwJEzVrTwQODEu8YBPmUG3UgA6ImiAmrmZAk0qdCgSV+eqCmz58acCjwIIEBga9evR79y
            ncrV6wwVKnhuPRq2atKvXp32PJvAQwECBfIWQJEXr168fv3mnZEAgl0DBjRoKLC4gAHGjyM3Tux4
            BoQUHjZoRmxg84bOMDR/Hr0h9IYZCA544MAhhujWHDbEhh2jtWbWtWc4cOBBBgffHVjL6AD8t+/f
            HILL8D3jwIIGM6JLn069uvQGCwo8b8C9u/fv4LlnDwIAOw==
        }] \
        arrowup-n [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1oR1a3t1a+fr3ufn
            3ufj3uff3v///3t1Y/f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1hAQEAAAAAAAACwAAAAA
            DwAPAAAFfaC0jGRJMkukruy6MFFABVMAyABFcWIk/JSfsCLgvCKFQaUySCqVHFRkYLEMDB2D1cpL
            HQwXbKdzORAMRtihgRi7D/Boiu2uIxBGSQTjSDgwfnwODkYpGQ8Ph4mJh1F6GhAPEJCIEJNyERsK
            EAobnJyeaREcpKWmpCImqiQhADs=
        }] \
        radio-du [image create photo -data { \
            R0lGODlhEQARAMQAAK2ejPfv7+/r5+/n597b1t7X1r2upd7Xzsa+tca6tf8AAOfj3uff3sa2rbWq
            nP/////7/62ilPf39/fz9+fj5722rf/3987DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA
            AAoALAAAAAARABEAAAVfoCKOZGme6Hg0ERA1R5o417EshZGcScUIlgfk8UDsSAfHIkBsEg2xUeNC
            GTqJhAYpUphcm5IICTAIfomA7eBMDJMaBPYjizTIoaUE4mzkGQgSDxIEOikrLS9RKYuMJyEAOw==
        }] \
        comboarrow-d [image create photo -data { \
            R0lGODlhEAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597j1t7f1v8AALWyrefr
            3ufn3ufj3uff3ufb3sa2rf////f39/fz9+/37+/z7+/v7+/r7+/n3u/j3u/f3ufj1uff1ufb1gAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAAwALAAAAAAQABgAAAbNwIlw
            SCSCGBOKcslcTkDJiqVSCUwB1kAFmgx4LZavmEsBhy0CtPViIQswgvd7ABcM3JiB3p7vk/UZBQMZ
            gIN3QhQGGQQGjAMGj49kjQYGGpSUB2QHBw2enw2NmoicCKANSpxkCAgHpp5KDqyrsrKoFBsIDg9k
            DxsPDwgPFAnBwb0cD8nFD8XJZBDKD9EQ1dW8iB3VERAdHtrdEGQeEREeHhDk6ehkEQof5eUK8R9k
            HxIfC/kL+PoLZCBASAgosB6IewAJKlT4pIjDIUeCAAA7
        }] \
        button-pa [image create photo -data { \
            R0lGODdhHAAcAMQAAO/r55ySe5yOe5yKe5yGe97b1tbTzs7LxtbLvZyShJyOhIR9c5yKhIR5c4R1
            c97bzpR9e4x9c4x5c4R9a4R5a4R1a3t1a5SOe5SKe5SGe5SCe4yKc4yGc4yCc+fb1gAAACwAAAAA
            HAAcAAAF/iBwVGRpnmh5iBXivnAsv9VhIUXx6F7h9b1HzycsAkkIj3C40/mIypzU56lQEELe0tiE
            QoUURzIH3AF5yvLwR7lqpepcM5v9NSbJetEJPGfREhJYa2ZURjxaQAt4ZU9RU0SOaxEReU9GaYeP
            dREdg16XhGRqHpQ4e5mOeo9UEJ4/kaJcZJgdGjhosU+7fkAat0NyWlxBiDwcGYNpZ460P0FAGRu4
            e4U7dFKrGcmFqrBpussZBGN04HxysH8eGBif4GZbvensA6dkVOhvUWsDDDg/Hlyb1yjgMwYX7j1L
            JEyPMA8CAiRRhw/KQmjfFCjAwgeatTmXzAQwkOCZyZMoEFEmMACAZIKXMGPKnPmSZQgAOw==
        }] \
        toolbutton-a [image create photo -data { \
            R0lGODdhGAAYANUAAPf77/f37/fz7/fv7+/z5+/v5+/r5+/n5+/j55ySe5yKe5SCc9bTzs7LxpyS
            hJyOhJyKhIR5c4x9c4x5c4R9a4R5a4R1a3t1a4SCc+fr3ufn3ufj3v///3t1Y//7///3//f/9/f7
            9/f39/fz9+/37+/z7+/v7+fv55SKe5SGe5SCe4yGc4yCc+/n3ufj1ufb1v//9//79//39wAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/kBDw0IsGo/HhtDC
            aTqfUKilcYlar68O0wPyeDhcDwwEBne7HNjLUuGEPKH3G04Pxez02KsS4Xzid392gyEyMiF/d3tt
            IoUAIpAyIjIAkiKPl5IvExQcIgEjIiOgAZ+QpaGhoC8SEhykoCQCoyMjJLQBtwEBLxQYHAKzsiPB
            ssHHtsesriMlswIlzbPO1MfOLywsHNXO0MHV3t0vKirbJQPOAwTq5wLo0OjqLwsrHAPxBOfn6CXr
            5/4DxqXYZmLdABPs4pnQh/DcixUDDxYwUYBAQXXrMh60SOBFChQcJg4ocI+kSJMISR58gQLkxJcU
            Tb4c+bJAAZYKOJwwwLOnUIECPnfyBGrghQIIHA5kyKCUqdOmBwwsPRD1BYQEHDQg0NCCq4avWxF0
            DQv2xYMHHDaoXcu2LVsXZhk4eEG3rt27dx0wMCDXgd+/gAMD3hsEADs=
        }] \
        button-p [image create photo -data { \
            R0lGODdhHAAcAMQAAMbDte/r59bPztbLzs7Pxs7Lxs7Hxs7Dxsa+vdbPxtbLxtbHxnNxa3Nta3Np
            a2ttY2tpY2tlY86+vXtxa3tta3NxY3NtY3NpY3NlY8a2rcbLvcbHvcbDvc7Lvc7Hvc7DvSwAAAAA
            HAAcAAAF/mDgRWRpnmjpiVHmvnAsv5EHZUSSEwMhDImeL9cr8ngQTEZBUACZzJwieJw2oQTM7Vg1
            9qLM73GQzAwKCkXhq05feWg4WgG5FZqEgl5d1Ofvak1oBRc3bYNqeoiHg3uEFxmKeh2NCh2JBZeS
            iRAPkQULeqGZkqKSo6AXkAuUoR2sBrAdBpQFtJMGmZ0Zs7a9trS5oL0GubCEDpGzs8EdzMG+t80O
            FhnFxR0e183c2ssGHhbJ2hrb2eDF2troHuXgDQ3WHvP0G+D22vgb8+D8D9X2Dmw4cMBDQYMIDQ48
            cK/gAQvV5u2biHBiwX0SD+6zEG/Dh4IfPXzw6NDjx30CjUcKbEAhw8iBGzzKfPnBQ8wPNWGKbFAh
            g0cOIz9wIDlQJdChOINuqBBvJFChOIceVYpzw1GgLDM85cB1KleoV6NGpdCza9KvV82m/VqBgVYO
            EjgA4BqX69y4eOXS5TphQoa5e+VKuNu1cF26FQxMACABAYK5jxFwkIwALwDHlzFPMBBAcd/PoEOL
            /sw5BAA7
        }] \
        comboarrow-p [image create photo -data { \
            R0lGODlhEAAYANUAAAAAAN7b1t7X1t7T1tbbztbXztbTztbPztbLzs7Pxs7Lxs7Hxs7DxmtpWt7X
            zt7Tzt7PztbTxtbPxtbLxtbHxmtpY2tlY/8AAHNlY8a2rcbLvcbHvcbDvefb1s7Lvc7Hvc7DvQAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABcALAAAAAAQABgAAAbfwIpl
            SCwSP5dKZslsMi0fpUAQEBCo2GsHI7VOvV9Bp4HJfAthNLozNBfe6kHBURh0KuX34CE31AsPBWwW
            GQMGh4cPh4YPY4SHBwYQiJRsDRkGBxERkZGZnHdlBwcApaYAnAdsShIJpKcSB7F3hLGxpgcICRII
            d0oTCboTAAoJCroKgxkKzM0KE853l80LChTMFB4LHqEZ29/a3wrcFUoLHx8L6hrf6t0bDB8bG+jx
            8h+rGSD0DCD9G/4YbBhThgMIDhsQAkS4b8ulgxANcpAIwleGDhgzasQIxYjHIxeCAAA7
        }] \
        button-n [image create photo -data { \
            R0lGODdhHAAcANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n55ySe5yOe5yKe5yGe97f1t7b
            1tbTzs7LxpyShJyOhIR9c5yKhIR5c4R1c97bzpR9e4x9c4x5c4R9a4R5a4R1a3t1a+fr3ufn3ufj
            3uff3ufb3v////f79/f39/fz9+/z7+/v7+/r7+fr55SOe5SKe5SGe5SCe4yKc4yGc4yCc+/r3u/n
            3u/j3u/f3ufj1uff1ufb1ufX1v/39wAAAAAAAAAAAAAAACwAAAAAHAAcAAAG/sADpEMsGo/IIkTY
            ITmf0Kj02YF4SCZTSbsz7brdUtcrLndzRGzABMiuTW924BTPZtEc0lwwn9P/ewJ/gn05HBYkJwKL
            giiMiygnJ5GQiouGeQIoA5uanJ+anZugAzkVGyQDBQMpqqopBa2trKyrKbClGhokBikGvb0EwQbC
            vsS/vgQpOROoBwYqBgfRz78H1cLXxNU5GRkk1CrP4dLl18/a190yJOfu7/Dw3d/wKwf28df46hjs
            CNcIPrj7d+DDv4AAzyHIIeNFu4IHDs6ISHHgOYMHcrxwSPCawY8fA/4LOTJHDBckDIpEMIMlApcR
            V478l8MFDBI0RH7MSSNktk8ENH6+/FATpcqcQFfmVBkwJwiRNRmQQADiaVWqVGlc1foUqFUaOVq0
            IPHUqVezWJ2W1bqwxQISIUCECFGDbl25dePWwIt3bo4FFODaEHHjRgjDIUQctpE4hA3Ejx3noMCC
            BI4GOERoviwiM47LnD1/xpxDQQISOXKMuNwgdQ4cOVqPcL26terUEiSQuOCAt44cvXX47s27twMd
            xB3kSPAgguvn0KNHj/DgQPMI2LNr384de/UgADs=
        }] \
        arrowright-d [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1rWyrefr3ufn3ufj
            3uff3sa2rf////f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFcCAkjmQJRWiqpmIUTIEUAC8wTVsr7NPuU4LcqTCgUBbEYlEYGVQqg8XCAIUyDwaLQbqw
            HAiGKwNx4C4OaOYYceGiEAjmpZFoSFGNPBPjcGAWKH58TBkPDg8ZEX0PiEwaCg8KGpGRk0wbmJma
            mCadIyEAOw==
        }] \
        arrowdown-d [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1rWyrefr3ufn3ufj
            3uff3sa2rf////f39/fz9+/z7+/v7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFayAkjmQJRWiqpmIUTIEUAC8wTVor7NPuU4LcqTCgUAbEYlEYGVQqA0MUCmUeDIusdkEw
            WBmI7QJ1YIIRFi0KgWBaGolGGtWoMy8OB94R0eOZGA8OD4F5D4RMGQoPChmMjI5MGpOUlZMmmCMh
            ADs=
        }] \
        radio-pu [image create photo -data { \
            R0lGODlhEQARAMQAAK2ejN7b1r2ypb2updbPzs7Lxs7Hxsa+vdbPxtbLxsa+tca6tf8AAM6+tca6
            rbWqnLWmnK2ilMbDvbWilM7Hvc7DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA
            AAwALAAAAAARABEAAAVeICOOZGme6Bg4EzA5QdpEw3IcC9SczaNQCQKCQBjsSIGIxEBsEiGxkUNQ
            GTqJCwdpsihcm4UJCVAJfomAbeVMDJMcCzYhi4TIoaXG4GzkQboEBTlHJystL1EpiosnIQA7
        }] \
        arrowright-p [image create photo -data { \
            R0lGODdhDwAPAMQAAAAAAN7b1t7X1t7T1tbbztbXztbTztbPztbLzs7Txs7Pxs7Lxs7Hxs7Dxmtp
            Wt7bzt7Xzt7TztbTxtbPxtbLxmtpY2tlY3NlY8a2rcbHvefb1s7Lvc7Hvc7DvQAAAAAAACwAAAAA
            DwAPAAAFgKBjjWRJVhWmrux6pYFABI8QC7jmXJhQ4BCfrwDRoDCFQaEAKESUSiMvYqgCANWsLmWQ
            HBJXwMHwNaYOisMkLFZMpBgFRaEII+QUzcWBWSwoC1d+G34aIxgMGwwMAIqKiUZ8GQwcDJMclRwZ
            cBkZHZ6fDZ0deikap6ippzsmrSQhADs=
        }] \
        blank [image create photo -data { \
            R0lGODlhGAAYAIAAAP8AAAAAACH5BAEAAAAALAAAAAAYABgAAAIWhI+py+0Po5y02ouz3rz7D4bi
            SJZTAQA7
        }] \
        button-d [image create photo -data { \
            R0lGODdhHAAcANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n597f1t7b1t7bzufr3ufn3ufj
            3uff3ufb3sa2rf////f79/f39/fz9+/z7+/v7+/r7+fr5+/r3u/n3u/j3u/f3ufj1uff1ufb1ufX
            1v/39wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAHAAcAAAG/sADKEIsGo/IIkgY
            kTif0Kj0GRlKKJRJVkQRcbkTbjdM5g6blAAFgFWnsetAxQ3HniVygVw+7+cFfYB7dxUChoAWh4YW
            FRWMi4WGdwIWA5WUlpmUl5WaA3cDBQMXoaEXBaSko6OiF6efRBIGFwazswS3Bri0urW0BBd3BwYY
            BgfFw7UHybjLusl3yBjD0sbWy8POy8LY3d7f3tzdGQfk4Mvm27EIywgM3ewHDOzu7dgI3O/0Ggf0
            3vHy2N0BGHAeA4Pu2CFUeGdeQgQaICKQ2O+hQoGxNiQ0qHEDQo8INoCcyKDhRI0hH2p06E5jg4QD
            G7yUiWDmBpo3X4a0eeeldMudP2umxHkTXywHDRw44LCUaVKmSDk8far0joMODzx4cLDVwQOuHbxe
            7dpha4c7HxJ8eMA27YO1H9K6hRtX7R0QICCkTYAXxAcQfCH01cs3L95YCxQkDgFCcYjFihMrVhAi
            soIhmPtq3sx5cxUmSUKHXhIEADs=
        }] \
        arrowleft-p [image create photo -data { \
            R0lGODdhDwAPAMQAAAAAAN7b1t7X1t7T1tbbztbXztbTztbPztbLzs7Txs7Pxs7Lxs7Hxs7Dxmtp
            Wt7bzt7Xzt7TztbTxtbPxtbLxmtpY2tlY3NlY8a2rcbHvefb1s7Lvc7Hvc7DvQAAAAAAACwAAAAA
            DwAPAAAFgKBjjWRJVhWmrux6pYFABI8QC7jmXJhQ4BCfrwDRoDCFQSFZACiVRl7EQDUAAFWDLmWQ
            HBJXwMHwNaYOikMYkFZMohgFRaEII+QUzcWBWSwoflcLG34aIxgMGwwMgwCKiUZ8GQwcDJMclRwZ
            cBkZHZ6fDZ0deikap6ippzsmrSQhADs=
        }] \
        check-dc [image create photo -data { \
            R0lGODlhEQARAMQAAK2ejO/r5+/n597b1tbTztbPzs7Lxv8AAL26tb22tbW2rbWyrefj3v/////7
            //f398bDve/v7+fn597f3r22rdbX1s7Pzv/39wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA
            AAcALAAAAAARABEAAAVc4CGOZGmeKKCu7EoCVyzPF/BeTa47FdHYI5hOZzDkgCKYw6ErIB7HGyTB
            aEgWEx3yAJMoFAEIYrgVMhaUxYB8y1kWCai23XAgLMMfvSGI5Ms4eWxBLYVbKIiJJSEAOw==
        }] \
        arrowleft-n [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1oR1a3t1a+fr3ufn
            3ufj3uff3v///3t1Y/f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1hAQEAAAAAAAACwAAAAA
            DwAPAAAFgaC0jGRJMkukruy6MFFABVMAyABFcWIk/JSfsCLgvCKFQaUyKHSUSg4qMrBYBoZO53rl
            pQ6GS1Z7ORAMRtihgdBqD/CDNMVGYNyIPMIoiWAcCQ53HX8ODkYpGQ8Pig8djIpSfRoQDxCUixCX
            cxEbChAKG6CgomkRHKipqqgiJq4kIQA7
        }] \
        sbthumb-vd [image create photo -data { \
            R0lGODdhDwAUAMQAAN7f1u/j3u/r5+fn3vf37+/n5+fj3vfz7+/j5+ff3vfv7+/z7/fr7+/v7+/r
            7+fj1v/z98a2rff39+ff1vfz9+fb1u/z5////+/n3u/v5+fr3gAAAAAAAAAAAAAAAAAAACwAAAAA
            DwAUAAAFi2AkjmQZXWiqpuJFHJYiCBoWPFPVUofSZJrCwJAA6E6vRcNRKCAMxONFQlkoMgLMIFCU
            vq6CJsaAk0JgMtozkfD2sM2twbjrLcPjaOtsnQm5dCdVPgxhWwk5dVZwQw9tLV8NhTVciUgHC1h4
            UI+CFAppGnKBLguLcUSdFxQ8mhhPZS0Vs7S1sya4IyEAOw==
        }] \
        combo-rp [image create photo -data { \
            R0lGODdhGAAYAMQAAMbDte/r59bPztbLzs7Pxs7Lxs7Hxs7Dxsa+vdbPxtbLxtbHxnNxa3Nta3Np
            a2ttY2tpY2tlY86+vXtxa3tta3NxY3NtY3NpY3NlY8a2rcbLvcbHvcbDvc7Lvc7Hvc7DvSwAAAAA
            GAAYAAAF/mDgRWRpnmg0ZmzrvnAGZURSEwMhDEmu17kgAZNREBQ5o5FwxDmXCsXM2Yw+m9UmcVAo
            KAo5r/ho5JYLs+63K/6u2WJvuuOOw9vq7iVz7xQWXQYdgF2DcA8ZBgWCBoqCgYp/HY1/BnuMipOT
            jJqOmh2Ikx6Yo4yloo2NDhkenQYar6WmjBqjFokGoxujHroeGwbAu7oGDay/BgceB7vKyrzLvBvG
            yrsb1r/YG9W/yrcbH8wHH9vgzB8e4eboGxUZHOTxG/Ac4Nv1Hxz4H8bz+fTx8sWD5w8ehQz/EtLT
            txBeQgbvJDCcKFEih4r6LE54xxDjxI8XAVw0MAGBBAQAGACgRMABAUqJLCWINAkgAMkJOHPq3Mkz
            BAA7
        }] \
        arrowdown-n [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1oR1a3t1a+fr3ufn
            3ufj3uff3v///3t1Y/f39/fz9+/z7+/v7+/n3u/j3ufj1uff1ufb1hAQEAAAAAAAAAAAACwAAAAA
            DwAPAAAFe6C0jGRJMkukruy6MFFABVMAyABFbWIk/JSfsCLYvCKFQaUySCqVG1RkYLEMDFerlZc6
            GDjgMIdgMMIODYSYc2hHU2nEJYyoI4ySyMWRcMz9DoFGKRgPD4WHh4VReRkQDxCOhhCRbxEaChAK
            GpqanGYRG6KjpKIiJqgkIQA7
        }] \
        sbthumb-va [image create photo -data { \
            R0lGODdhDwAUAMQAAHt1a/f77+/r5+fn3v/3//f37+/n5/fz7+/37/fv7+/z7//79/fr7/f/93t1
            Y+/v7//39/f79+/r7/f394R1a/fz9+fb1u/z5////+/n3u/v5+fr3v/7/wAAAAAAAAAAACwAAAAA
            DwAUAAAFj6BDASNViiJJYWzrtia2LEF1HJogbIMVcxHIBHFJaDaGXqyxmEwqiYdkZ/CtOITIUKHJ
            Ja2YRrBwSCR0PDCHZuNODdXYQkuO5gTK60JYUZypahFaNw9eeRhAfH6GgVoIi4Bye084Ol9LgmR+
            aHFXBJQ4d4dzTwhmRwYZap+aGgw7hxays7SyJhQpACK3ACohADs=
        }] \
        arrowup-d [image create photo -data { \
            R0lGODdhDwAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1rWyrefr3ufn3ufj
            3uff3sa2rf////f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFaSAkjmQJRWiqpmIUTIEUAC8wTVsr7NPuU4LcqTCgUAbEYlEYGVQqA8PCAIUyDwaLdLGw
            HAiGKwPBLR/OzHF5jUAwL43ECtVgYhyOez5/Z2YeDg9/eA+CTBoKDwoaioqMTBuRkpORJpYjIQA7
        }] \
        tree-h [image create photo -data { \
            R0lGODdhGAAYANUAAPf37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j54R1a3t1a+fr3ufn3ufj3v//
            /3t1Y//7///3//f/9/f79/f39/fz9+/37+/z7+/v7+/r7+fr5+/r3u/n3u/j3ufb1v/79//39wAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sBHYkgsGo9Eh3LJ
            bDodCoUSInFIIA6IFnvNUqkeYfYK+XwnErP5ev1MPAnpBDKZz+n4idtODyccERMUIBOBgxMgFIiE
            gYRwf4qEFJOJhImKk4gUcFIUAJUAnqKTg6Sfjw6hAKoUFaGurp4ArgAeCg8OFQGuu7sWAcDBvLqo
            FRe9F8a7x8zBx2G4FwLNAcfV19PYqBcEAt3e3tIC4NLdBJwOAhgFAgUF6xjt7u3t6wKo7u8ZBfv8
            BQPu1v1758dBv3wGCiRUyHBhQnQGImqISLGixYjQHERcYIAjxwMdO4LkuBHVggMHNqBUeTLlgZYv
            VaI6wOBkzZc0OSxgQPMmLU10DDow4DCUgVEEDBAQRSo0KKoGRhsI7QA1KgOoWIWi8sC1q9evYG8h
            GTs2CAA7
        }] \
        progress-v [image create photo -data { \
            R0lGODdhEwAoALMAAK2+znuarYSitXuWrYSetXuSrYSatVJha3uapXuWpXOapYSerXuSpXOWpXOS
            pXuerSwAAAAAEwAoAAAE5fDISWsFOOuNJVjEYwTkMAhoKnih8TxkoKreEwbGONMHQLgu2Q7lqC2C
            Q1Sh2CO0koLG0rMQQZcOpo8ATTSkWm6yMQBroYNEodDIepIBRfk77Q1NJjX2PTMFTA0MUit2KjGA
            bAUofCgiJAiIKYwwJQOQipKFjn+QcjNvQZt/O1QthyekTSIvMUk1NzlCQyxAMFBaD0e2SXVbVmO9
            VQZXWWFiQ15gLFBkZow7aWttZ0Nxc8qFfXh6btkpfoCCis8Cp1KDhAAqm5BlmOkplH+WA+/wApv0
            njzqoSMlqT6YqjTLgkELEQAAOw==
        }] \
        tab-n [image create photo -data { \
            R0lGODlhHAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r55ySe5yKe5SKc5yOhJyKhIR5c4x9
            c4x5c4R9a4R5a4R1a/8AAISitYSCc/////fz9+/37+/z7+/v7+/r75SKe5SGe5SCe4yGc4yCc+fb
            1sbDxlJla1JhawAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABMALAAAAAAcABgAAAb+wImI
            RCwaj8iiSEiiOJ/QqPRJEo2m2OxTYrkELoCvOCAOe73fc0gSsYzPZzE6Hg9FGl2B4LIP7P9pX318
            e3ZtAl8Yen8XGISKAo6IfBchDxAWAhmUf4uLnJ0ZApYOFqKLooSaF6ebmqujDhWZAgOiA3qnnraL
            uHohDqW8uBm2A8bFp7wZxaMgIKbGBcTH07fJx7XFISAemdgD0wXFx83S2gMhHh8Wxxrh7+/w4uED
            7/QhHR0WBgP9x/7iHev3r5+Gf/n22TNwkCFBgv4WHlxoIIQCDvwGEDBAYONGDR4ZeiTgj2NFDhgN
            qGyocqNKky9bOgzBIQG/AxtxGtiwM+RDBp0meRIIkYCBBZ4wefI8oBKpgQNMYYZYgOAm1KdMdRJg
            uvUq1KwhECywkPXrz7JesWKFOnWC27dw48qdS7eu3QlBAAA7
        }] \
        scaletrough-h [image create photo -data { \
            R0lGODlhHgAPAJEAAK2ejNbLvf8AAMa2rSH5BAEAAAIALAAAAAAeAA8AAAIolI+py+0Po5xUgouz
            3hyPD4biSF5DgKbqyrJmC8dpR9dZhef6zvdOAQA7
        }] \
        toolbutton-pa [image create photo -data { \
            R0lGODdhGAAYAMQAAO/r55ySe5yKe5SCc97b1tbTzs7LxtbLvZyShJyOhJyKhIR5c97bzox9c4x5
            c4R9a4R5a4R1a3t1a4SCc3t1Y5SKe5SGe5SCe4yGc4yCc+fb1gAAAAAAAAAAAAAAAAAAACwAAAAA
            GAAYAAAF0iBgRGRpnqchRkfrvjAcGdJBEAyuEdq+MzseEEhhaYDBHI4nPN54EcgBqEMOnbejD7I4
            BH05n07bhEirT3DyRtU4Ht72cOkTIxuN6TfM01L/Gg8TXkJMWE+FPnhxTFd+ZE4aGRl6TVk6WUo9
            GhcXNnN+hnJaAxheYEyFV5qcFjZjialffRiuQWxVqz86FhV6WmKGmZsaFb5sTnw5f09AFQJTsk1q
            iRoCCoSAVHTIPgoBlWRhVnY9CQmflz3caFoJBQjE8vPyCAUA8Aj6+/z9/PchAAA7
        }] \
        check-nc [image create photo -data { \
            R0lGODlhEQARANUAAAAAAK2ejHN1c2tpa1pdWlJRUkpJSrW2tbWyta2ura2qrf8AAJyanJSWlJSS
            lISChP/////7//f39/fz9+/v7zk4Oefn5+fj5zEwMRgYGMbDxhAUEBAQEAgMCAgICAAEAP/39wAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAAsALAAAAAARABEAAAZowIVw
            SCwaj8iAcslcEgOgqHQKCjxBkKxWIhhArEOoNisxFCLf64SiJWwsWbAQWuEwIAqAQytfQBMeHwcY
            GRJ8VxANAB0AD2N9YhAEixePiBAUGQRjaWFYWQganJCfnIdhTal9SKytRUEAOw==
        }] \
        tree-p [image create photo -data { \
            R0lGODdhGAAYAMQAAN7b1t7X1t7T1tbbztbXztbTztbPztbLzs7Txs7Pxs7Lxs7Hxs7DxmtpWt7X
            zt7Tzt7PztbTxtbPxtbLxtbHxmtpY2tlY3NlY8a2rcbLvcbHvcbDvefb1s7Lvc7Hvc7DvSwAAAAA
            GAAYAAAF/mBjjWRpntZVYWzrvjBWrUAwAHUd7MAQ6D4Ap3HB2HY73xHpUwY4lhUhQJhOqVjr7jos
            CggO6jc8dRAE3y+VM8NUv4X3eV6NnwscFaZQEPQLD3yCfH6BfVBFg4IQfAYFjIt8bA0YjgYRBpYR
            jY4Fl5l4I5UImZ+YpgakmaRDlAkGEgavErGysLGzmXlFEgkHCRK/v77Bs8IJUCsHEwq/CszNCQoJ
            E9TSzYgYCtvP3d3Q3NBDFhgU3Nwd2+nqCwrryRgdCwvy9Pb2CvP1C60YHvbyMvzzkMEewQUeCEIh
            p8EDg4QPF2hY8JDBRIcNGWSzqIGjRYsfNHT0IPLDBw95KlZo+LAhJMuVLl223LByIYYNOGeazMkS
            Z0+WuzBwGEq0qNGjFUSgWIoiBAA7
        }] \
        check-nu [image create photo -data { \
            R0lGODlhEQARAJEAAK2ejP8AAP/////39yH5BAEAAAEALAAAAAARABEAAAIxjI+py+APHwKj2jvA
            HKL7rx3URwqhMZbeGaSqub0d66o0J98yLOKvnptEhiyG8ZgoAAA7
        }] \
        sep-v [image create photo -data { \
            R0lGODdhAgAUAIAAAN7Tzv/7/ywAAAAAAgAUAAACB0SMp8nrnQoAOw==
        }] \
        toolbutton-p [image create photo -data { \
            R0lGODdhGAAYANUAAMbDte/r59bPztbLzs7Pxs7Lxs7Hxs7DxmtpWsa+vdbPxtbLxtbHxnNxa3Nt
            a3Npa2ttY2tpY2tlY86+vXtxa3tta3NxY3NtY3NpY3NlY8a2rcbLvcbHvcbDvc7Lvc7Hvc7DvQAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sDAR0IsGo/Hj1Ci
            aTqfUKjkE9EQFFfCgCAYKLbc63aMyGgWhMUWjSaktfD2QlKFvxfo9fueLmsGBQULBVuChml5gloR
            VYGDgYaDj5CGBRiNHpKVlJGOlhganB4FDIEGHqWBqJAQEBoGBacGsKemsKQes6QYoLKwubmywLTA
            rRq5H77JssvIswYPDxofwwYb1svMshsfFxevBskcyR/iHxwG6OPiDg7T5wYHHwfj8vLk8+QX7vLj
            HP7nAHLod+6Ag28cQNA7AGJgQnogPih8GNGCBQ0dGmrkkLFDwoEeQXQI2U4DR5EdNYrUmPFkBwcV
            NKCc2XFkzYwoKzTAOMGmNc+ePTsAHdmzAQWMNof6XCoUQAcKBigkmJAAAICqCTokqNoz6wSnCaAG
            iEqhrNmzaM8aCBAEADs=
        }] \
        arrowdown-p [image create photo -data { \
            R0lGODdhDwAPAMQAAAAAAN7b1t7X1t7T1tbbztbXztbTztbPztbLzs7Txs7Pxs7Lxs7Hxs7Dxmtp
            Wt7bzt7Xzt7TztbTxtbPxtbLxmtpY2tlY3NlY8a2rcbHvefb1s7Lvc7Hvc7DvQAAAAAAACwAAAAA
            DwAPAAAFfaBjjWRJVhWmrux6pYFABI8QC7jmXJhQ4BCfrwDRoDCFQSFZiCiVRl7EQDVMqwZdyiAB
            eL+AQ8KYOigO4LBiEsUoKArFF/GmaC4OzGJB2QP2G3saIxgMGwwMC4eHhkZ5GQwcDJAckhwZbRkZ
            HZucDZoddykapKWmpDsmqiQhADs=
        }] \
        arrowright-a [image create photo -data { \
            R0lGODdhDwAPAMQAAPf77/f37/fz7/fv7+/z5+/v5+/r5+/n54R1a3t1a+fr3ufn3v///3t1Y//7
            ///3//f/9/f79/f39/fz9+/37+/z7+/v7+/r7+fb1hAQEP/79//39wAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFf2CDjGRJJgijruyKJIzmQLMjOzgmxpH29MBIBPNiADaSSAYg2UScGBRjIqlmMoFqVZcS
            UCaUa2YiABNhAsKgIs4IKpVoqjCwFMT1wYDYYBgKF3cZBX8FBUQpBgoGBhmMjwZRfQoHlJSKB5Vy
            DAsLB52fn55nDBimp6imIiasJCEAOw==
        }] \
        sbthumb-hn [image create photo -data { \
            R0lGODdhFAAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1oR1a3t1a+fr3ufn
            3ufj3uff3v///3t1Y/f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAACwAAAAA
            FAAPAAAFm6C0jGRpmlGqrqy6MFFABVMAyAA1yzInRoIgJUisECkVCucVKQwqlYHzSY0aOYxFZGCx
            DAxfrxj8xWoPhovhwL4cCAYCe+2DHRqIQz7P7usPS1p4CBgIgwiIeHgYSxIRGA4JDhiSkA6TlgmB
            ERkPD52fn52jno0RGhAPEKieEKupqhpmERsKEAobt7e5ubYbWDAcwsPExcInyMkhADs=
        }] \
        sbthumb-hp [image create photo -data { \
            R0lGODdhFAAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1oR1a3t1a+fr3ufn
            3ufj3uff3v///3t1Y/f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAACwAAAAA
            FAAPAAAFm6C0jGRpmlGqrqy6MFFABVMAyAA1yzInRoIgJUisECkVCucVKQwqlYHzSY0aOYxFZGCx
            DAxfrxj8xWoPhovhwL4cCAYCe+2DHRqIQz7P7usPS1p4CBgIgwiIeHgYSxIRGA4JDhiSkA6TlgmB
            ERkPD52fn52jno0RGhAPEKieEKupqhpmERsKEAobt7e5ubYbWDAcwsPExcInyMkhADs=
        }] \
        arrowleft-a [image create photo -data { \
            R0lGODdhDwAPAMQAAPf77/f37/fz7/fv7+/z5+/v5+/r5+/n54R1a3t1a+fr3ufn3v///3t1Y//7
            ///3//f/9/f79/f39/fz9+/37+/z7+/v7+/r7+fb1hAQEP/79//39wAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFfWCDjGRJJgijruyKJIzmQLMjOzgmxpH29MBIBPNiADaSyAaQ2SiHKMZEQg1kMlSqLiWg
            TCjXzETwJcIEhEE4UxFUKphoYWAphOmDAbHBMBQuBQZXfgUFRCkGCgaLgowGcXwKB5KSiQeTcSkL
            CwebnZ2cZgwYpKWmpCImqiQhADs=
        }] \
        combo-rn [image create photo -data { \
            R0lGODdhGAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n55ySe5yKe97f1t7b1tbTzs7L
            xpyShJyOhJyKhIR5c97bzox9c4R9a4R5a4R1a3t1a4SCc+fr3ufn3ufj3uff3ufb3v////f79/f3
            9/fz9/fv9+/37+/z7+/v7+/r75SKe5SGe5SCe4yGc4yCc+/r3u/n3u/j3ufj1uff1ufb1v/39wAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sCD40IsGo/Iy/DD
            bDqf0A/mEwqBrLPQLJsFZbXe8IUaCAGq5UC5CgiI1mvLhyQSuOnvfEDAzwtEJBIfI3x8IyWFfCUD
            AyWEAo4CciYFA5UmJgOZl5SalZYDFR8mBgSlp6QGpCamBKSmJhQfBgcGtLSmByentae3GR8HwrTC
            tcXFu8gHssfNzs8swcUazdTPxSrBLQgtBwga397e3ePhBysfCAje1Ovq1ODx7uApH9vg6uHu3Pz8
            Bxr1ELjYMFCeBoMC5SFA8WGDOocIHBKMKNAFRXUDGRKUONBiR4kEBzp0oaAhhxccTqbcoPIFy5Ms
            UXKI8KEDDBg2cerM2YHDO80OPXEm+LDAQ4wYC44m9VAUqVGjTWNA+MCgKgMZV7FW1Xp164SrDR7I
            GEu2rNmzMg6EfcC2rdu3cIMAADs=
        }] \
        comboarrow-n [image create photo -data { \
            R0lGODlhEAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597j1t7f1s7LxoR1a/8A
            AHt1a+fr3ufn3ufj3uff3ufb3v///3t1Y/f39/fz9+/37+/z7+/v7+/r7+/n3u/j3u/f3ufj1uff
            1ufb1hAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAA4ALAAAAAAQABgAAAbgwIZw
            SCQyHI+KcslcNhjJC+ZyCUwB1sBF1EgGvhgMeCyyNCphMUawtmYw3LNAI5jPB3TBQPSQawaAen+D
            cRWAGwUDG4eKe2YVBhsEBpMDBpaWXBaQkwYclAagB3xnBwcjqKkjlKNCFaYIqiOmpoUICAexqLcQ
            t3xJCL29I8EdwRGFER0REQjNCc3NfJsRHtUR0NjXhRLX3RLg4MhdFR/gExIfIObpEqQVIBMTICAS
            8fb1XEkTCiHy8gr+hShzJgSFEAsQLjiYcIGmCiJEUIgocaAIg/ogUty48UmRj0OOBAEAOw==
        }] \
        sizegrip [image create photo -data { \
            R0lGODdhEAAQAJEAAO/r58a2rf///wAAACwAAAAAEAAQAAACJoSPqXvCKsJDcTZpQdVz7+VhIPZB
            JGkaYbJqonrCbOyqco1X7VoAADs=
        }] \
        combo-rf [image create photo -data { \
            R0lGODdhGAAYANUAAPf37/fz7/fv7/fr7+/z5+/v5+/r5+/n55ySe5yKe97f1t7b1tbTzs7LxpyS
            hJyOhJyKhIR5c97bzmNdUox9c4R9a4R5a4R1a3t1a4SCc+fr3ufn3ufj3uff3ufb3v////f79/f3
            9/fz9/fv9+/37+/z7+/v7+/r75SKe5SGe5SCe4yGc4yCc+/r3u/n3u/j3ufj1uff1ufb1v/39wAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/kBD40IsGo/Iy/DD
            bDqf0A/mEwqBrLPQLJsFZbXe8IU6CZUnAPTZnE6HAFXLhyQKAER00X0f6OsnAXgRHyOAfSMlfYol
            AgIlI32PAXImBAKWJiYCmpiVmwQTlwIVHyYTAwWoqCYFBawmqqyrFB8FBq23BqgGJ6m2rQMTvxkf
            BhO5Bsm2ycy9zQa0zNLT1MfJLMXWGtPb1NIqxS0HLQYHGubl5eTqE90rHwfH6Afl6Of39OYHKR/i
            5wcAt+UbRzAePQ384m1wsQGfBocHXOA7gOLDBoAXD1xcqDGii44TIm6ouGHCRoYfUW5cyPCiiwQW
            ObzgIJPmhpovbsosOZMDTIQPHSbA6ABjqFGiQzkU7dBBaQcEHxR4mBCD6gQFE6ZOxVq1qocYMR58
            WEB2gQyzZ8mmNatWglkGDmTInUu3rl0ZBuA62Mu3r9+/QQAAOw==
        }] \
        combo-ra [image create photo -data { \
            R0lGODdhGAAYANUAAPf77/f37/fz7/fv7+/z5+/v5+/r5+/n5+/j55ySe5yKe9bTzs7LxpyShJyO
            hJyKhIR5c4x9c4R9a4R5a4R1a3t1a4SCc+fr3ufn3ufj3v/////7///3//f/9/f79/f39/fz9+/3
            7+/z7+/v7+fv55SKe5SGe5SCe4yGc4yCc+/n3ufj1ufb1v//9//79//39wAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/kADg0IsGo9IylDD
            bDqfUE0lSqVSNJvOZoPVtjrYbpbb2k40no0nnVa7PS6426WGaDjrOB7O97xeHnh6HmcffgAfiS8f
            LwCLH4iQi34SGh8BIB8gmAGXiZ2ZmZwfERqcmCECmyAgIasBrgGcFhoCqqkgtqm2vK29AqUgIqoC
            IsKqw8m8ySIpGsrDxbbK0tG2J88iA8MDBN3aAtvF298CKBoD5ATa2tsi3trw5CbPI94DI9/kI+z5
            7AT08BUYUYCAvW7eEuIz6G1ECQ0DBxRINzFixXwTBRZ4OLAjwYodJXYsMHGEAg0kDKhcaaAAy5Qq
            Xa58oOHAhQs2cerMecDANc0DPXEm0IABAQYVRzEoNYoAKdOlSh1oyEC1qtWrVldQXdCAhdevYMOK
            ZWGAa4OzaNOqXRsEADs=
        }] \
        sbthumb-ha [image create photo -data { \
            R0lGODdhFAAPAMQAAPf77/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n54R1a3t1a+fr3ufn3v///3t1
            Y//7///3//f/9/f79/f39/fz9+/37+/z7+/v7+/r7+/n3ufb1v/79//39wAAAAAAAAAAACwAAAAA
            FAAPAAAFmaCTjGRpmk2qrqyaKM32RPMjP/hGy5oYSxsIcCgZCiGaVwPAmUg4gAnnSZ1YNYpEg2Kd
            BCiBrvULxmoFFUpFwKYI1G60oAcTFAYWPF5gsfAFeElaBgMXhAYXhQMDh4xJDg0HBhgGB5SSBpWY
            BIKRCwegoaKgn48NCwioqAeoqakHqWYNDAwItLa2tboZDFgwGsDBwsPAJ8bHIQA7
        }] \
        tree-n [image create photo -data { \
            R0lGODdhGAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597j1t7f1oR1a3t1a+fr
            3ufn3ufj3uff3ufb3v///3t1Y/f39/fz9/fv9+/37+/z7+/v7+/r7+/r3u/n3u/j3u/f3ufj1uff
            1ufb1gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/kAKY0gsGo/EiXLJ
            bDonjcakUglUAVSspUqtAAKWgEg4CVvM4IAajRYzpBiLABxnBwR4s2DMmFzweBcZgHgZAwMZfwIZ
            IkMTi4gDkIaGi5WGA41SAwUDGpygBZ+fnoedjX0GAwaqBhoEqrCwqwawBiINFBMbtQYHsLysBwes
            sAe8qBPGBMTLvs/DxAdjugcI0djZ19EIyQccCOAIDuPWCOHX6A6aE+cd4w8I7+Md5PYI8ckPHfEJ
            HQkPHgD0F28fwG5kAAYMCOGBh4APIzJ8wO4BhIgeLkLQmPGiw4zUJmwcCQEEhAglN35IuRFEMhAR
            UMY8CVNmzQgmIySLEEIBNk+fMEPgFBqiZ8wQ7BZIKLqAaQgJSkNEXao0mYimIq5KECEV6YKrYME6
            ykq2rNmzuIQgWYskCAA7
        }] \
        combo-rd [image create photo -data { \
            R0lGODdhGAAYANUAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n597f1t7b1t7bzufr3ufn3ufj
            3uff3ufb3sa2rf////f79/f39/fz9/fv9+/37+/z7+/v7+/r7+/r3u/n3u/j3ufj1uff1ufb1v/3
            9wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACwAAAAAGAAYAAAG/sADKEIsGo/IyFDC
            bDqfUElEQqFMrCFKKJudZLXe8JQSoACq5UC5CghU1uvppSJwz9/4gGCPF1QuUxZ7exYYg3sYAwMY
            ggKMAlMZBQOTGRkDl5WSmJOUA5EGBKGjGQYGpRmiBKWiGVMGB6axB6IHGqOxo7AGUwe+sL6zwb63
            wRoHvcPKy8vJvgzK0MzBvRsIGwcIDNrZ2dje3MgSCAjZ0OXk0Nvr6NtT1tvk3OjX9fUHDFMIHA38
            7Az/9rFDMKUBOYMIDPZLuI8DQ3L8CvJLyM9hRYX9+BnkUNBBBwceQTYI2WGkx5EfHUx54MEDS5cw
            Xz5w0PLBTJdTEkD48CEBJk+fEHT23LlT6IcpCpIqALGUaVKnS58uaKoEhNWrWLNqFZKka5IgADs=
        }] \
        arrowup-a [image create photo -data { \
            R0lGODdhDwAPAMQAAPf77/f37/fz7/fv7+/z5+/v5+/r5+/n54R1a3t1a+fr3ufn3v///3t1Y//7
            ///3//f/9/f79/f39/fz9+/37+/z7+/r7+fb1hAQEP/79//39wAAAAAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFeWCDjGRJJgijruyKJEzmQLMjO/glxlH29MBI5PJiADSSiAYg0SiHKMZEQg1gAlSqLiWg
            TCiY8ETwJcIEhEF4LahULtGCer0eDIgNhqFgKRj6ewUFRCkGCgaIiYlweQoHjo6GB49wKQsLB5eZ
            mZhmDBegoaKgIiamJCEAOw==
        }] \
        combo-n [image create photo -data { \
            R0lGODdhGAAYAJEAAO/r59bTzpyShP///ywAAAAAGAAYAAACPUSEqctyAKOcFAgwst68j+uFHiiW
            GWmKaDpibLi+Wyyfbj3fuL3nvUarBWXDV5F1TCVNy1JTdPhlDI1qowAAOw==
        }] \
        arrowdown-a [image create photo -data { \
            R0lGODdhDwAPAMQAAPf77/f37/fz7/fv7+/z5+/v5+/r5+/n54R1a3t1a+fr3ufn3v///3t1Y//7
            ///3//f/9/f79/f39/fz9+/37+/z7+/v7+/r7+fb1hAQEP/79//39wAAAAAAAAAAAAAAACwAAAAA
            DwAPAAAFemCDjGRJJgijruyKJIzmQLMjOzgmxpH29MBIBPNiADaSyAYg2SiHKMZEQg1MAlSqLiWg
            ZL7gzIRChAkIg3BGUKlgooWBpQCWDwbEBsNQuBQMGX8Fg0QpBgoGiYqKb3oKB4+PhweQbykLCweY
            mpqZZQwYoaKjoSImpyQhADs=
        }] \
        comboarrow-a [image create photo -data { \
            R0lGODlhEAAYANUAAPf37/fz7/fv7+/z5+/v5+/r5+/n587LxoR1a/8AAHt1a+fr3ufn3ufj3v//
            /3t1Y//7//f/9/f79/f39/fz9+/37+/z7+/v7+/r7+fr5+/r3u/n3u/j3ufb1hAQEP/79//39wAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAAkALAAAAAAQABgAAAbWQIRw
            SCQeEgqHcslcIg5JCMQBiUyr2A4iKZFYIV7I5wPuPBBUqQQsXq+1aFC3K5dPJKCOAn0HTfx9E3dw
            DoAAgoiAZmiHFACOE4eSWg8OARQVj5cBlwABemicHqOkHhYUn0IOFhYCpR6cFqloAgKtpLUDtXpJ
            AgS+rhcEv8OEw8PCFxgEyXqVBAXQBMvT0oQFGdgF29zbWkkG2+EGC+QF4aAO5eQLGuXu7d8O5AwG
            9uQb9gyLDgwcDAAB/gtIyUGDBhwQImRw0J+8DhAjSoT4pIjFIUeCAAA7
        }] \
        scale-hd [image create photo -data { \
            R0lGODlhHgAPAMQAAO/r5+/n5+/j597f1t7b1t7X1t7T1t7fzt7bzt7Xzt7Tzv8AAOfr3ufn3ufj
            3uff3ufb3sa2rf/////7/+/r3u/n3u/j3ufj1uff1ufb1ufX1gAAAAAAAAAAAAAAAAAAACH5BAEA
            AAsALAAAAAAeAA8AAAXN4JJFZGme6JmJkeS+cCzH0SgxQQAEOMXsOxwOQMkVhQqSJNBoMHPOaKX5
            jFYryVbDYWkItl2Lo2Hpfs1NsTcrcbjfbnFk4pjX6fA3+/JwPPiAdw9zgxN9f4gPbA8YGA8DD4yR
            cwOUlI+RAxgDbAMZmp+bmpYTlRMYEI0DEBkYbAcEGQSenp9zIxMEcwQEB7KwnEoaCATExbzExMPH
            GgTDzbxsCAUICdTU1tbT2tgJ3Ahs3gbe5OPeCgno4uTqCkkj7vHy8/T0NSwp+fr3IQA7
        }] \
        progress-h [image create photo -data { \
            R0lGODdhKAATALMAAK2+znuerXuarXuWrXuSrXOapXOWpXOSpXuapXuWpXuSpYSitYSetYSatYSe
            rVJhaywAAAAAKAATAAAEzvDJSau9uILNu/9guEmAwwQnYzJL67omiq5v7ZBpE7O12+S7no9BCjQC
            RqOwhUwmG8tFk3QUHKFLozWwxQq1DZIgKYhyx+OqWYAWW8vLt7wBF84F7npvwBbw+1F/fmwkfIF/
            AwiDh2yJfoVRg4kDfAORlQiUjw8AgQWUlAifnqCJoyRLBgmgBqBRqqyuC6g9qwSqBrcEUba4ui60
            L7e5uQq5UcO6xrvAnDUGB8TEzELQ0r8vwQsEBAfd3t7I3d/jPcEH6OnpUertQhnw8fERADs=
        }] \
        radio-dc [image create photo -data { \
            R0lGODlhEQARANUAAK2ejPfv7+/r5+/n597b1t7X1r2upc7Lxt7Xznt1c6WenISCe8a+tca6tf8A
            AIyOjLWyrefj3uff3sa2rZyalLWqnP/////7/62ilMbHvff398bDvffz94yKhOfj597f3r22rdbX
            1tbT1s7PzsbHxv/3987DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAA4ALAAAAAARABEAAAaHQIdw
            SCwaj8ghYoIBYCaIZKNiQkQiBUPj2ABJBCXLxWJhbImISiQQglAgIbIhOpyYPKJD6BMixQkTRBgF
            HHAFIxkPEBYaGEQAAyUUH4gbCxRkAIIDFnAZGx0Ji41EEwQWfQ8LCQp/gUoGZG1vcRZzRQ0MZLtk
            ZlwGBBqMBFpJS01PdEnLzEdBADs=
        }] \
        check-au [image create photo -data { \
            R0lGODlhEQARAJEAAK2ejP8AAP/////39yH5BAEAAAEALAAAAAARABEAAAIxjI+py+APHwKj2jvA
            HKL7rx3URwqhMZbeGaSqub0d66o0J98yLOKvnptEhiyG8ZgoAAA7
        }] \
        scale-vd [image create photo -data { \
            R0lGODlhDwAeAMQAAO/r5+/n5+/j597j1t7f1t7b1t7X1t7T1tbXzt7bzt7Xzt7Tzv8AAOfr3ufn
            3ufj3uff3ufb3sa2rf/////7/+/n3u/j3ufj1uff1ufb1ufX1gAAAAAAAAAAAAAAAAAAACH5BAEA
            AAwALAAAAAAPAB4AAAXTIJNJZGlKmShNbOtO6AoAwWw380JOdRP4v6BuFSg6gsXicHI8VpqB49Ih
            oFqf0p3F4dg+qpbq1Lvdch/Th+XR7ZaXj7h8jt49IHHIRX+vr/AQJ3xLEAMQFIiIEItLGI4YBBCR
            BJGEkicYEBiNBBiJiJCbOxkZBBkRpqalSwWmJwWtSxkFGZ8UGQkZSwmwGgW+BbwFSxoGCQnGyca7
            yAYax8/LOwYGCgkKCtXZCUvY2d7aBksHCwoICuXe6Dve5e4LCAtL8vTw9vEx9fryKConJylCAAA7
        }] \
        radio-nu [image create photo -data { \
            R0lGODlhEQARAMQAAK2ejPfv7+/r5+/n597b1t7X1r2upd7Xzsa+tca6tf8AAOfj3uff3sa2rbWq
            nP/////7/62ilPf39/fz9+fj5722rf/3987DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA
            AAoALAAAAAARABEAAAVfoCKOZGme6Hg0ERA1R5o417EshZGcScUIlgfk8UDsSAfHIkBsEg2xUeNC
            GTqJhAYpUphcm5IICTAIfomA7eBMDJMaBPYjizTIoaUE4mzkGQgSDxIEOikrLS9RKYuMJyEAOw==
        }] \
        sbthumb-hd [image create photo -data { \
            R0lGODdhFAAPAMQAAP/z9/f37/fz7/fv7/fr7+/z5+/v5+/r5+/n5+/j597f1ufr3ufn3ufj3uff
            3sa2rf////f39/fz9+/z7+/v7+/r7+/n3u/j3ufj1uff1ufb1gAAAAAAAAAAAAAAAAAAACwAAAAA
            FAAPAAAFjOAjjmRpQmiqrqkIBVIQBQAMSDEMa67gS77gJCiZSHgPSGEwmQyWzKhziIQMKJSBQZvt
            brXVg6FiOJgrB4KBYC6HF4hDPG6uyw9VOMKC0CP+cHAWVRYMCQwWh4UMiIsJVRcNDZGTk5GXklUY
            Dg0Om5IOnpydGFUZCg4KGampq6uoGVUas7S1trMmubohADs=
        }] \
        check-du [image create photo -data { \
            R0lGODlhEQARAJEAAK2ejP8AAP/////39yH5BAEAAAEALAAAAAARABEAAAIxjI+py+APHwKj2jvA
            HKL7rx3URwqhMZbeGaSqub0d66o0J98yLOKvnptEhiyG8ZgoAAA7
        }] \
        sep-h [image create photo -data { \
            R0lGODdhFAACAIAAAN7Tzv/7/ywAAAAAFAACAAACB4SPmcHt/woAOw==
        }] \
        radio-au [image create photo -data { \
            R0lGODlhEQARAMQAAK2ejPfv7+/r5+/n597b1t7X1r2upd7Xzsa+tf8AAM6+tefj3uff3sa6rbWq
            nP/////7//f39/fz9+fj5722rbWilP/3987DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA
            AAkALAAAAAARABEAAAVcYCKOZGme6Eg0FVA1RKo417EshaGcCsUIlgfk8UDsSATHIkBsEg2xUeMy
            GTqJK1KlILk2IxUSYBD0EgHagZkIJsHWj6zKAIeWFAizkQeNPCIEOikrLS9RKYiJJyEAOw==
        }] \
        radio-ac [image create photo -data { \
            R0lGODlhEQARANUAAAAAAK2ejPfv7+/r5+/n597b1t7X1r2upXt5e3Nxc1pZWkpJSt7Xzsa+tf8A
            AJyanJSWlIyOjM6+tefj3uff3sa6rZyWlLWqnP/////7//f39/fz9zk8OTk4Oefj5yksKb22rSEg
            IbWilP/3987DvQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAAA4ALAAAAAARABEAAAaBQIdw
            SCwaj8hhoSIKiCqFpORCYkwmhoPkKAFRBiNMBoNpbImFy0Rg6QA6D/IhOqyQPJBFIpLgxJdEIgYb
            HQkIChxvGBoiRAEEIwARiB8AAGQBgQQYhRyVioxEUBgPiZYhfxVoB2QPbnBydEMSDWS2ZGZccxqL
            BVpJS01PsknFxkZBADs=
        }] \
        arrowup-p [image create photo -data { \
            R0lGODdhDwAPAMQAAAAAAN7b1t7X1t7T1tbbztbXztbTztbPzs7Txs7Pxs7Lxs7Hxs7DxmtpWt7b
            zt7Xzt7TztbTxtbPxtbLxmtpY2tlY3NlY8a2rcbHvefb1s7Lvc7Hvc7DvQAAAAAAAAAAACwAAAAA
            DwAPAAAFfGBTjWRJUtSlruxqpYFABI4QC3jWWJdQ4A+fr/DIoC6FQSFZgCiVRh7EQDUAqlRdyhA5
            IADgg8FrTB0SB7D6LIleEhO1fDLJWBoXhWKi5ys0ehkjFwsaCwt/hYcaRngYCxsLjxuRGxhuGBgc
            mpsMmRx2KRmjpKWjOyapJCEAOw==
        }] \
        sbthumb-vp [image create photo -data { \
            R0lGODdhDwAUAMQAAN7f1u/j3nt1a+/r5+fn3vf37+/n5+fj3vfz7+/j5+ff3vfv7+/z7/fr73t1
            Y+/v7+/r7+fj1v/z9/f39+ff1oR1a/fz9+fb1u/z5////+/n3u/v5+fr3gAAAAAAAAAAACwAAAAA
            DwAUAAAFlKBTCWNViiJZZWzrtmZWINgyDJwWRNQVW4jFY8MxEA4KgG81YzwgBkPigFxmJhbGYjPQ
            EAJJ62w7iGoOPKuEZsNNFQpxkBv9HpS/4LN8rsbWWjdGYHgrWUINZV8KPXladEcRcTFjD4k5YI1M
            CAxcfFSThhYLbRx2hTIMj3VIoRkWQJ4aU2kxF7e4ubcmFSkCIrwCKiEAOw==
        }] \
        tab-a [image create photo -data { \
            R0lGODlhHAAYANUAAN7f1t7b1t7X1t7T1tbbztbXztbTztbPzs7Txt7bzt7Xzt7Tzt7PztbTxtbP
            xnNxa3Nta3Npa2ttY2tpY2tlY/8AAHtxa3tta3NxY3NtY3NpY3NlY+ff3ufb3v///97f3t7b3s7H
            vQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAQQAAAAAAAAAAAAAAACH5BAEAABUALAAAAAAcABgAAAb+wIpw
            SCwaj8ikUhiiOJ/QqPQZqjQ92Kx2y81SQhMPgAMYj8lowEeN/qQ5k42no17TP2s8oEO/78t4E2Fl
            IAABhH90ZYcAIIeFhRphhx0BdIWHAZqWAY57moYAGxoem6aOm6iaqp2aExKlAQKas6amtbSbAhqk
            AgSyuQKzw7+yxQSzBK8eCcS1wsi0zbLD0xoRHr7a2gQKwtvcwt4EERnZ3wUF3wLq7ezv7gUZEB7u
            AwID6fn39u0F/BDo5UuXbsE/fQcHGhxg8F8GcwUW7BtggGLFixX/MTTwr2IGDB4McBxZwMACkhRL
            ioy40sC8kCJFnoxJU6ZNmxAueDhgoAE2g548ecYU2oDmTwMHHjzw0CBoU6AHmkYNCnVqgwcWdko9
            4OCAV6ldm0pF0LXrAQtL0qpdayQIADs=
        }] \
    ]
#       spinarrowup-d [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAOVBMVEXGtq3////39+/38/f39/f/
#           8/fn29b38+/v8+/v8+f37+/v7+/v7+e1sq3v6+fv6+/36+/n697v5+fd/CZmAAAAOklEQVQIHQXB
#           wQGAIAwEsByFh/tvi0hNAAAiANCTJ3qku9NnT+atL1I9DgOrgusOJpUX9EJkAWADAPylEBEeX7C+
#           XAAAAABJRU5ErkJggg==
#       }] \
#       spinarrowup-a [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAQlBMVEV7dWOEdWt7dWv/////+/f/
#           +//3//fn29b3+/f/9//3++//9/f39/f38/f39+8QEBD38+/v9+/v8+f37+/v8+/v7+eB+1ZZAAAA
#           PklEQVQIHQXBgQ3CMBAAMV9IQGL/ZSuqPnYCgGoBwLP5Dqt58LsWr9NJ7Y529L6xfGiN0w1mxrTa
#           ALgKAPgDUCoOOTBnMcQAAAAASUVORK5CYII=
#       }] \
#       spinarrowup-p [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAQlBMVEVraVprZWNraWPGtq1zZWPe
#           29be19bW287e287n29bW187e187e09be087W084AAADW08bWz87O08bOz8bWz8bWy8bd9/yHAAAA
#           PUlEQVQIHQXBsQ2AMBAEMN99RMH+u6ZABOwIACQNAGT1u4N88Owe6azImKVlxoszLa32gNNomgsA
#           O+sFAD+WsAs5wPvaCgAAAABJRU5ErkJggg==
#       }] \
#       spinarrowup-n [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAP1BMVEV7dWOEdWt7dWv////39+/3
#           8/f39/f/8/fn29b38+/v8+/v8+f37+/v7+/v7+cQEBDv6+fv6+/36+/n697v5+cMLf7xAAAAQElE
#           QVQIHQXBwQ3DMBADMOpsP7r/sgGaWiUjAJBkAOBuPtFJ2/R9NvuuX2R1XplwVnDdkd2sfEEPzeQA
#           4EkAgD/3IxMkVV6ZGwAAAABJRU5ErkJggg==
#       }] \
#       spinarrowdown-d [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAP1BMVEXGtq3////39+/38/f39/f/
#           8/fn29b38+/v8+/v8+f37+/v7+/v7+fv6+e1sq336+/n697v5+fv597n597v4+cnxBvMAAAAOElE
#           QVQI12XNKxYAIAwDQWpQfJqG+58VCIYH60ZtSm92t11LO/WSZYdoVmUHQgTk4GAskpTz1Xebpl8C
#           xZjcoHYAAAAASUVORK5CYII=
#       }] \
#       spinarrowdown-a [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAS1BMVEV7dWOEdWt7dWv/////+/f/
#           +//3//fn29b3+/f/9//3++//9/f39/f38/f39+/38+/v9+8QEBDv8+f37+/v8+/v7+fv7+/v6+fv
#           6+81NFeQAAAAP0lEQVQIHQXBQQ7CQAwEMM80ai/8/6sIhDbYEQBIUgA4wysBftf7O6E5cB7Sdeca
#           9Nm1XW3dZrYlzQDgkwAAfzQpDURzs85IAAAAAElFTkSuQmCC
#       }] \
#       spinarrowdown-p [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAAS1BMVEVraVprZWNraWPGtq1zZWPe
#           29be19bW287e287n29bW187e187e09be087W087W08YAAADWz87O08bOz8bWz8bWy8bWy87Oy8bO
#           y73IIUV2AAAAQElEQVQIHQXBwQ2DQBAEMM+wIQ/6rxUhcbnYEQBIGgDIcCVAcj/D0d+GNEx3y+Jc
#           pfMeQ+f5+mxWmhMAd2YBgD+t6w00F+PP4wAAAABJRU5ErkJggg==
#       }] \
#       spinarrowdown-n [image create photo -data { \
#           iVBORw0KGgoAAAANSUhEUgAAAA8AAAAICAMAAAARDVXAAAAARVBMVEV7dWOEdWt7dWv////39+/3
#           8/f39/f/8/fn29b38+/v8+/v8+f37+/v7+/v7+fv6+cQEBD36+/n697v5+fv597n597v4+ekAoEk
#           AAAAPUlEQVQIHQXBQRZAQAwFsPxOZ+f+Z8VDJREASFIA8DXHFJD3vir0AvNFaqxorO42PSqZfvYE
#           UtkAOBMA4AdyuQ42kTaoZgAAAABJRU5ErkJggg==
#       }] \

    ttk::style theme create clearlooks -parent clam -settings {

        ttk::style configure . \
            -borderwidth        1 \
            -background         $colors(-frame) \
            -foreground         black \
            -bordercolor        $colors(-darkest) \
            -darkcolor          $colors(-dark) \
            -lightcolor         $colors(-lighter) \
            -troughcolor        $colors(-troughcolor) \
            -selectforeground   $colors(-selectfg) \
            -selectbackground   $colors(-selectbg) \
            -font               TkDefaultFont \
            ;

        ttk::style map . \
            -background [list disabled $colors(-frame) \
                             active $colors(-lighter)] \
            -foreground [list disabled $colors(-disabledfg)] \
            -selectbackground [list !focus $colors(-darker)] \
            -selectforeground [list !focus white] \
            ;


#        ttk::style configure Frame.border -relief groove

        ## Treeview.
        #
        ttk::style element create Treeheading.cell image \
            [list $I(tree-n) \
                 selected $I(tree-p) \
                 disabled $I(tree-d) \
                 pressed $I(tree-p) \
                 active $I(tree-h) \
                ] \
            -border 4 -sticky ew

        #ttk::style configure Treeview -fieldbackground white
        ttk::style configure Row -background "#efefef"
        ttk::style map Row -background [list \
                                       {focus selected} "#71869e" \
                                       selected "#969286" \
                                       alternate white]
        ttk::style map Item -foreground [list selected white]
        ttk::style map Cell -foreground [list selected white]


        ## Buttons.
        #
        ttk::style configure TButton -padding {10 0}
        ttk::style layout TButton {
            Button.button -children {
                Button.focus -children {
                    Button.padding -children {
                        Button.label
                    }
                }
            }
        }

        ttk::style element create button image \
            [list $I(button-n) \
                 pressed $I(button-p) \
                 {selected active} $I(button-pa) \
                 selected $I(button-p) \
                 active $I(button-a) \
                 disabled $I(button-d) \
                ] \
            -border 4 -sticky ew


        ## Checkbuttons.
        #
        ttk::style element create Checkbutton.indicator image \
            [list $I(check-nu) \
                 {disabled selected} $I(check-dc) \
                 disabled $I(check-du) \
                 {pressed selected} $I(check-pc) \
                 pressed $I(check-pu) \
                 {active selected} $I(check-ac) \
                 active $I(check-au) \
                 selected $I(check-nc) ] \
            -width 24 -sticky w

        ttk::style map TCheckbutton -background [list active $colors(-checklight)]
        ttk::style configure TCheckbutton -padding 1


        ## Radiobuttons.
        #
        ttk::style element create Radiobutton.indicator image \
             [list $I(radio-nu) \
                  {disabled selected} $I(radio-dc) \
                  disabled $I(radio-du) \
                  {pressed selected} $I(radio-pc) \
                  pressed $I(radio-pu) \
                  {active selected} $I(radio-ac) \
                  active $I(radio-au) \
                  selected $I(radio-nc) ] \
            -width 24 -sticky w

        ttk::style map TRadiobutton -background [list active $colors(-checklight)]
        ttk::style configure TRadiobutton -padding 1


        ## Menubuttons.
        #
        #ttk::style configure TMenubutton -relief raised -padding {10 2}
#     ttk::style element create Menubutton.border image $I(toolbutton-n) \
#         -map [list \
#                       pressed $I(toolbutton-p) \
#                       selected $I(toolbutton-p) \
#                       active $I(toolbutton-a) \
#                       disabled $I(toolbutton-n)] \
#         -border {4 7 4 7} -sticky nsew

        ttk::style element create Menubutton.border image \
             [list $I(button-n) \
                  selected $I(button-p) \
                  disabled $I(button-d) \
                  active $I(button-a) \
                 ] \
            -border 4 -sticky ew


        ## Toolbar buttons.
        #
        ttk::style configure Toolbutton -padding -5 -relief flat
        ttk::style configure Toolbutton.label -padding 0 -relief flat

        ttk::style element create Toolbutton.border image \
            [list $I(blank) \
                 pressed $I(toolbutton-p) \
                 {selected active} $I(toolbutton-pa) \
                 selected $I(toolbutton-p) \
                 active $I(toolbutton-a) \
                 disabled $I(blank)] \
            -border 11 -sticky nsew


        ## Entry widgets.
        #
        ttk::style configure TEntry -padding 1 -insertwidth 1 \
            -fieldbackground white

        ttk::style map TEntry \
            -fieldbackground [list readonly $colors(-frame)] \
            -bordercolor     [list focus $colors(-selectbg)] \
            -lightcolor      [list focus $colors(-entryfocus)] \
            -darkcolor       [list focus $colors(-entryfocus)] \
            ;


        ## Combobox.
        #
        ttk::style configure TCombobox -selectbackground $colors(-selectbg)
        ttk::style configure TCombobox -arrowsize 16 -padding 0

        ttk::style element create Combobox.downarrow image \
            [list $I(comboarrow-n) \
                 disabled $I(comboarrow-d) \
                 pressed $I(comboarrow-p) \
                 active $I(comboarrow-a) \
                ] \
            -border 1 -sticky {}

        ttk::style element create Combobox.field image \
            [list $I(combo-n) \
                 {readonly disabled} $I(combo-rd) \
                 {readonly pressed} $I(combo-rp) \
                 {readonly focus} $I(combo-rf) \
                 readonly $I(combo-rn) \
                ] \
            -border 4 -sticky ew


	# Combobox popdown frame
	ttk::style layout ComboboxPopdownFrame {
	    ComboboxPopdownFrame.border -sticky nswe
	}
 	ttk::style configure ComboboxPopdownFrame \
	    -borderwidth 1 -relief solid


        ## Notebooks.
        #
#         ttk::style element create tab image $I(tab-a) -border {2 2 2 0} \
#             -map [list selected $I(tab-n)]

        ttk::style configure TNotebook.Tab -padding {6 2 6 2}
        ttk::style map TNotebook.Tab \
            -padding [list selected {6 4 6 2}] \
            -background [list selected $colors(-frame) {} $colors(-tabbg)] \
            -lightcolor [list selected $colors(-lighter) {} $colors(-dark)] \
            -bordercolor [list selected $colors(-darkest) {} $colors(-tabborder)] \
            ;

        ## Labelframes.
        #
        ttk::style configure TLabelframe -borderwidth 2 -relief groove


        ## Scrollbars.
        #
        ttk::style layout Vertical.TScrollbar {
            Scrollbar.trough -sticky ns -children {
                Scrollbar.uparrow -side top
                Scrollbar.downarrow -side bottom
                Vertical.Scrollbar.thumb -side top -expand true -sticky ns
            }
        }

        ttk::style layout Horizontal.TScrollbar {
            Scrollbar.trough -sticky we -children {
                Scrollbar.leftarrow -side left
                Scrollbar.rightarrow -side right
                Horizontal.Scrollbar.thumb -side left -expand true -sticky we
            }
        }

        ttk::style element create Horizontal.Scrollbar.thumb image \
            [list $I(sbthumb-hn) \
                 disabled $I(sbthumb-hd) \
                 pressed $I(sbthumb-ha) \
                 active $I(sbthumb-ha)] \
            -border 3

        ttk::style element create Vertical.Scrollbar.thumb image \
            [list $I(sbthumb-vn) \
                 disabled $I(sbthumb-vd) \
                 pressed $I(sbthumb-va) \
                 active $I(sbthumb-va)] \
            -border 3

        foreach dir {up down left right} {
            ttk::style element create ${dir}arrow image \
                [list $I(arrow${dir}-n) \
                     disabled $I(arrow${dir}-d) \
                     pressed $I(arrow${dir}-p) \
                     active $I(arrow${dir}-a)] \
                -border 1 -sticky {}
        }

        ttk::style configure TScrollbar -bordercolor $colors(-troughborder)


        ## Scales.
        #
        ttk::style element create Scale.slider image \
            [list $I(scale-hn) \
                 disabled $I(scale-hd) \
                 active $I(scale-ha) \
                ]

        ttk::style element create Scale.trough image $I(scaletrough-h) \
            -border 2 -sticky ew -padding 0

        ttk::style element create Vertical.Scale.slider image \
            [list $I(scale-vn) \
                 disabled $I(scale-vd) \
                 active $I(scale-va) \
                ]
        ttk::style element create Vertical.Scale.trough image $I(scaletrough-v) \
            -border 2 -sticky ns -padding 0

        ttk::style configure TScale -bordercolor $colors(-troughborder)


        ## Progressbar.
        #
        ttk::style element create Horizontal.Progressbar.pbar image $I(progress-h) \
            -border {2 2 1 1}
        ttk::style element create Vertical.Progressbar.pbar image $I(progress-v) \
            -border {2 2 1 1}

        ttk::style configure TProgressbar -bordercolor $colors(-troughborder)


        ## Spinbox.
        #
#       foreach dir {up down} {
#           ttk::style element create Spinbox.${dir}arrow image \
#               [list $I(spinarrow${dir}-n) \
#                    disabled $I(spinarrow${dir}-d) \
#                    pressed $I(spinarrow${dir}-p) \
#                    active $I(spinarrow${dir}-a)] \
#               -border 1 -sticky {}
#       }


        ## Statusbar parts.
        #
        ttk::style element create sizegrip image $I(sizegrip)


        ## Paned window parts.
        #
#         ttk::style element create hsash image $I(hseparator-n) -border {2 0} \
#             -map [list {active !disabled} $I(hseparator-a)]
#         ttk::style element create vsash image $I(vseparator-n) -border {0 2} \
#             -map [list {active !disabled} $I(vseparator-a)]

        ttk::style configure Sash -sashthickness 6 -gripcount 16


        ## Separator.
        #
        #ttk::style element create separator image $I(sep-h)
        #ttk::style element create hseparator image $I(sep-h)
        #ttk::style element create vseparator image $I(sep-v)

    }
}

