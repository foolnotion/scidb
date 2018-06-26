### scidblue - Copyright (C) 2018 Uwe Klimmek
### Available under the BSD-like 2-clause Tcl License as described in LICENSE in this folder
##########################################################################################
###
### scidblue.tcl: modern gray blue theme
###
##########################################################################################
### I've replaced the images for spinarrowdown-* and spinarrowup-*, because this fits better
### with other styles. (GC)
namespace eval ttk::theme::scidblue {

    package provide ttk::theme::scidblue 0.9

    array set I [list \
		arrowdown-a [image create photo -data { \
			R0lGODlhDAAOAMZMAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufm5+jn6Ojo6Ojo6ejp6enp6erp6urq6+vs6+vr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PHx
			8fT09PX19fb39vf39///////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdsgH9LS0dHRjqINzZ/f0U4MjEwJiEiGA2MRYqRKCYgGA6YNpCSJhuf
			mACpqqmXjTqrqRutjjarIBsQoTYxqZ0QGJg3kC+TGxqzOrvEpRq5rjYwMCgiIMeYyZEmpRjOLgsK
			CQgGBgQDAYzo6emBADs=
		}] \
		arrowdown-d [image create photo -data { \
			R0lGODlhDAAOAMZMAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufm5+jn6Ojo6Ojo6ejp6enp6erp6urq6+vs6+vr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PHx
			8fT09PX19fb39vf39///////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdsgH9LS0dHRjqINzZ/f0U4MjEwJiEiGA2MRYqRKCYgGA6YNpCSJhuf
			mAGpqqmXjTqrqRutjjarIBsQoTYxqZ0QGJg3kC+TGxqzOrvEpRq5rjYwMCgiIMeYyZEmpRjOLgsK
			CQgGBgQDAYzo6emBADs=
		}] \
		arrowdown-n [image create photo -data { \
			R0lGODlhDAAOAMZMAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufm5+jn6Ojo6Ojo6ejp6enp6erp6urq6+vs6+vr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PHx
			8fT09PX19fb39vf39///////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdsgH9LS0dHRjqINzZ/f0U4MjEwJiEiGA2MRYqRKCYgGA6YNpCSJhuf
			mACpqqmXjTqrqRutjjarIBsQoTYxqZ0QGJg3kC+TGxqzOrvEpRq5rjYwMCgiIMeYyZEmpRjOLgsK
			CQgGBgQDAYzo6emBADs=
		}] \
		arrowdown-p [image create photo -data { \
			R0lGODlhDAAOAMZMAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufm5+jn6Ojo6Ojo6ejp6enp6erp6urq6+vs6+vr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PHx
			8fT09PX19fb39vf39///////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdtgH9LS0dHRjqINzZ/f0U4MjEwJiEiGA2MRYqRKCYgGA6YNpCSJhuf
			oaMmpZaYOgCvsBuXjTg2sAAgGxChNjGvnRAYmDeQL5MbGrNFOr3GpRq7jcwwMCgiIMmtvaSm0S4L
			CgkIBgYEAwGM6erqgQA7
		}] \
		arrowleft-a [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsbe3t76+vsPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKy8vKy8rLy8vLy8rKzMvLzM3Mzc3N
			zc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uLh4eHh4uLh4uHi4uXl5eXl
			5ufn5+fn6Ojo6Ojp6enp6erq6uvq6uzs7O/v7u/u7+7v7+/v7/Dw8PLy8vP09PX19ff29vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdwgH+Cg4SFRj8/QIqJikA8K39GOzc7OzaVADWVDpE0NDOgMwAAnjQK
			f0IwqqqjAKsJqC2yLa0Aswh/OyQnJiS1JSckBbkfJCEhvqMky8M7Gx4bzx6j0RsDfzYW2hYb3ADa
			1n80EOQMDeQQDOkBhe2DgQA7
		}] \
		arrowleft-d [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsbe3t76+vsPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKy8vKy8rLy8vLy8rKzMvLzM3Mzc3N
			zc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uLh4eHh4uLh4uHi4uXl5eXl
			5ufn5+fn6Ojo6Ojp6enp6erq6uvq6uzs7O/v7u/u7+7v7+/v7/Dw8PLy8vP09PX19ff29vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdwgH+Cg4SFRj8/QIqJikA8K39GOzc7OzaVATWVDpE0NDOgMwEBnjQK
			f0IwqqqjAasJqC2yLa0Bswh/OyQnJiS1JSckBbkfJCEhvqMky8M7Gx4bzx6j0RsDfzYW2hYb3AHa
			1n80EOQMDeQQDOkBhe2DgQA7
		}] \
		arrowleft-n [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsbe3t76+vsPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKy8vKy8rLy8vLy8rKzMvLzM3Mzc3N
			zc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uLh4eHh4uLh4uHi4uXl5eXl
			5ufn5+fn6Ojo6Ojp6enp6erq6uvq6uzs7O/v7u/u7+7v7+/v7/Dw8PLy8vP09PX19ff29vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdwgH+Cg4SFRj8/QIqJikA8K39GOzc7OzaVADWVDpE0NDOgMwAAnjQK
			f0IwqqqjAKsJqC2yLa0Aswh/OyQnJiS1JSckBbkfJCEhvqMky8M7Gx4bzx6j0RsDfzYW2hYb3ADa
			1n80EOQMDeQQDOkBhe2DgQA7
		}] \
		arrowleft-p [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsbe3t76+vsPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKy8vKy8rLy8vLy8rKzMvLzM3Mzc3N
			zc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uLh4eHh4uLh4uHi4uXl5eXl
			5ufn5+fn6Ojo6Ojp6enp6erq6uvq6uzs7O/v7u/u7+7v7+/v7/Dw8PLy8vP09PX19ff29vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdxgH+Cg4SFRj8/QIqJikA8K39GOzc7OzaVNTWVDpE0NDOgMwCengp/
			QjCpqQAAqjAJpy2yLawAsy0IfzskJyYktSUlJyQFuh8kISG/ACTNxLobHhvRHgDT0wN/NhbcFhve
			3RvZNBDlDA3lEAzqAYXug4EAOw==
		}] \
		arrowright-a [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvLzM3M
			zc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXl5eXl5ufm
			5+jn6Ojo6Ojo6ejp6enp6erp6urq6+zs7O/v7u/u7+7v7+/v7/Dw8PHx8fT09PX19fb39vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdxgH+Cg4SERkCIiYhBiCt/RjQ2NgA4kpY2C39DMTE0AAA0oTQxMgp/
			QTCpnwCprQmnLrGrALGxCH88JbqzJycrIgV/OCLEq8THwTgbICCfG88bHxsEfzUZ1wAZGxkRGxYb
			A380C+QO5hEOEQsRAYXuhIEAOw==
		}] \
		arrowright-d [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvLzM3M
			zc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXl5eXl5ufm
			5+jn6Ojo6Ojo6ejp6enp6erp6urq6+zs7O/v7u/u7+7v7+/v7/Dw8PHx8fT09PX19fb39vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdxgH+Cg4SERkCIiYhBiCt/RjQ2NgE4kpY2C39DMTE0AQE0oTQxMgp/
			QTCpnwGprQmnLrGrAbGxCH88JbqzJycrIgV/OCLEq8THwTgbICCfG88bHxsEfzUZ1wEZGxkRGxYb
			A380C+QO5hEOEQsRAYXuhIEAOw==
		}] \
		arrowright-n [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvLzM3M
			zc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXl5eXl5ufm
			5+jn6Ojo6Ojo6ejp6enp6erp6urq6+zs7O/v7u/u7+7v7+/v7/Dw8PHx8fT09PX19fb39vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdxgH+Cg4SERkCIiYhBiCt/RjQ2NgA4kpY2C39DMTE0AAA0oTQxMgp/
			QTCpnwCprQmnLrGrALGxCH88JbqzJycrIgV/OCLEq8THwTgbICCfG88bHxsEfzUZ1wAZGxkRGxYb
			A380C+QO5hEOEQsRAYXuhIEAOw==
		}] \
		arrowright-p [image create photo -data { \
			R0lGODlhDgAMAMZHAAAAAI6OjpCQkJGRkpOUlJWVlpeWlpmZmbCwsLe3t729vcPDxMPDxcTDxcPE
			xMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvLzM3M
			zc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXl5eXl5ufm
			5+jn6Ojo6Ojo6ejp6enp6erp6urq6+zs7O/v7u/u7+7v7+/v7/Dw8PHx8fT09PX19fb39vf39///
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAOAAwAAAdygH+Cg4SERkCIiYhBiCt/RjQ2kjiSlTYLf0MxMTQ0AJ2dMTIKf0Ew
			pzAAAKinCaUusC6qALEuCH88JbolsycnKyIFfzgixSKqxsXCOBsgzgAb0RsfGwR/NRnZ2RsZERsW
			GwN/NAvlDucRDhELEQGF74SBADs=
		}] \
		arrowup-a [image create photo -data { \
			R0lGODlhDAAOAMZLAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufn5+fn6Ojo6Ojo6ejp6enp6erq6uvq6uvr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PLx8vP0
			9PX19ff29vf39///////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdmgH+Cg4SDSkpHRkI8Pjw3M4JCOjMxLyMjGxsMkZOVKCQbGJt/QTiU
			LygjIBgVkaaemJqCpZQAAJiigkM8M7a2oaNGPL6+Gwu6xMSjtJWXmcudLy2quX+7MrDPgi0LCgkI
			BeEDAX+BADs=
		}] \
		arrowup-d [image create photo -data { \
			R0lGODlhDAAOAMZLAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufn5+fn6Ojo6Ojo6ejp6enp6erq6uvq6uvr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PLx8vP0
			9PX19ff29vf39///////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdmgH+Cg4SDSkpHRkI8Pjw3M4JCOjMxLyMjGxsMkZOVKCQbGJt/QTiU
			LygjIBgVkaaemJqCpZQBAZiigkM8M7a2oaNGPL6+Gwu6xMSjtJWXmcudLy2quX+7MrDPgi0LCgkI
			BeEDAX+BADs=
		}] \
		arrowup-n [image create photo -data { \
			R0lGODlhDAAOAMZLAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufn5+fn6Ojo6Ojo6ejp6enp6erq6uvq6uvr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PLx8vP0
			9PX19ff29vf39///////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdmgH+Cg4SDSkpHRkI8Pjw3M4JCOjMxLyMjGxsMkZOVKCQbGJt/QTiU
			LygjIBgVkaaemJqCpZQAAJiigkM8M7a2oaNGPL6+Gwu6xMSjtJWXmcudLy2quX+7MrDPgi0LCgkI
			BeEDAX+BADs=
		}] \
		arrowup-p [image create photo -data { \
			R0lGODlhDAAOAMZLAAAAAI6Oj5CPkZKRkpSUlJWUlpaWl5mZmbCwsLe3t729vcPDw8PDxMPDxcTD
			xcPExMTExMTExcbFxsbFx8XGx8bGxsbGx8jIyMjIycnIycjJycrKysrKy8vKy8rLy8vLy8rKzMvL
			zM3Mzc3Nzc3Mzs3Nzs/Pz9DPz8/P0M/Q0NDQ0NLR0tLR09HS0tLS0t3d3d3d3uHh4eTk5eXk5eXl
			5eXl5ufn5+fn6Ojo6Ojo6ejp6enp6erq6uvq6uvr7Ovs7Ozs7O/v7u/u7+7v7+/v7/Dw8PLx8vP0
			9PX19ff29vf39///////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMAA4AAAdngH+Cg4SDSkpHRkI8Pjw3M4JCOjMxLyMjGxsMkZOVKCQbGJt/QTiU
			LygjIBgVkaaemJqCpZQAAJiigkM8M7a2oaNGPL6+Gwu6r5axo7SVl5nMnS8tqrl/uzKw0IItCwoJ
			CAXiAwF/gQA7
		}] \
		blank [image create photo -data { \
			R0lGODlhGAAYAIAAAP8AAAAAACH5BAEAAAAALAAAAAAYABgAAAIWhI+py+0Po5y02ouz3rz7D4bi
			SJZTAQA7
		}] \
		button-a2pixel [image create photo -data { \
			R0lGODlhHAAcAKU1AFtzxF92xWB3xWh9x2h+x3aKzniLzpWl2Jal2Zem2qSu0aSv0dDS09PT1NLT
			19TU1NbW1tfX19DX7NHY7NjY2NLY7dnZ2dvb29zc2d3d3d7e3uDg4Nvg8tvh8OHh4eLi4uTk5OXl
			5efn5+jo6Onp6evr6+zs7O7u7vDw8PHx8fLy8vPz8/L0+fT09PX19/n49/r6+vv6+/v7+v79/v7+
			/v///////////////////////////////////////////yH5BAEKAD8ALAAAAAAcABwAAAb1wBon
			IQAYj8hkUpDgCA0TpXQKmBSGlVhMBuvCtFyveAyTEAGttHrNbquRqrh8Tq/Lkam8fs/v65EogYKD
			hIWCSCeJiouMjYpIJpGSk5SVkkglmZqbnJ2aSCShoqOkpaJII6mqq6ytqkYBACKztLW2t7RIIbu8
			vb6/vEggw8TFxsfESB/LzM3Oz8xIHtPU1dbX1Egb29zd3t/cSBrj5OXm5+RIGevs7e7v7EgX8/T1
			9vf0SBb7/P3+//yQUBhIsKDBgwSRRFjIsKHDhwxhAYBAsaLFixgrAgiAYMGDjyBDihwJUgECDgSo
			qEwywAmHAytVBjjgJAgAOw==
		}] \
		button-a [image create photo -data { \
			R0lGODlhHAAcAKU1AFtzxF92xWB3xWh9x2h+x3aKzniLzpWl2Jal2Zem2qSu0aSv0dDS09PT1NLT
			19TU1NbW1tfX19DX7NHY7NjY2NLY7dnZ2dvb29zc2d3d3d7e3uDg4Nvg8tvh8OHh4eLi4uTk5OXl
			5efn5+jo6Onp6evr6+zs7O7u7vDw8PHx8fLy8vPz8/L0+fT09PX19/n49/r6+vv6+/v7+v79/v7+
			/v///////////////////////////////////////////yH5BAEKAD8ALAAAAAAcABwAAAb+wBon
			IQAYj8hkUpDgCA2TDmtGq1qvWNqM1ZkUhpVYTAYrw8Rks3oNkxBdrbh8Tq/LXcWXas/v+/98L0Yr
			KYWGh4iJhitGKI6PkJGSkUYnlpeYmZqZRiaen6ChoqFGJaanqKmqqUYkrq+wsbKxRiO2t7i5urkA
			ASK/wMHCw8JGIcfIycrLykYgz9DR0tPSRh/X2Nna29pGHt/g4eLj4kYb5+jp6uvqRhrv8PHy8/JG
			Gff4+fr7+kYX/wADChwo0IiFgwgTKlyo0AiFhxAjSpwo0QiGCBgzatzIMSOGXg4giBxJsqTJkQ4C
			IFjwoKXLlzBjulSAgAMBmS8bMMD5QOcOACccDgRQQpRogANOggAAOw==
		}] \
		button-default [image create photo -data { \
			R0lGODlhHAAcAKU3AI2NjY6Ojo+Pj5CQkJGRkZOTk5SUlJeXl5mZmZubm52dnZ6enqCgoKKioqWl
			paenp6urq6ysrLCwsLGxsbKysrS0tLW1tba2tre3t7m5ubu7u9LS0tPT09TU1NXV1djY2NnZ2dra
			2tvb293d3d7e3uDg4OHh4eLi4uTk5OXl5efn5+jo6Onp6evr6+zs7O7u7vDw8PLy8vPz8/b29vf3
			9/39/f7+/v///////////////////////////////////yH5BAEKAD8ALAAAAAAcABwAAAb+wF+l
			MikajRRLhXI8Ui6/H0ajctFqtqx2y7XVaC5V5idxwczoszrNXsMkENpMTp/b6/j7DPLI+/V/Dw4y
			MYSGhYiHiokxDg0wkJGSk5STDQwvmZqbnJ2cDAsuoqOkpaalCwktq6ytrq+uCQgstLW2t7i3CAcr
			vb6/wMHABwYqxsfIycrJBggpz9DR0tPSCg4o2Nna29zbERAn4eLj5OXkfCbp6uvs7eyCJfHy8/T1
			9I4k+fr7/P38lyMCChxIsCBBUCISKlzIsCHDVCAiSpxIsSJFWR8yatzIsSPHXSJChBwpsiTJkyZD
			EOvAsqXLlzBfGjiggUMHDx5itsTZweYmzZwcNBz4UWCDT50uOWxIuqFAlB8EAgCYSnVqgAECpFal
			GoBAlCAAOw==
		}] \
		button-d [image create photo -data { \
			R0lGODlhHAAcAKUxAKCgoKGhoaKioqOjo6SkpKWlpaampqmpqaqqqqysrK6urrCwsLKysrS0tLa2
			trm5ubq6ur29vb6+vr+/v8HBwcLCwsPDw8XFxcfHx9ra2tvb29zc3N/f3+Dg4OHh4ePj4+Tk5OXl
			5ebm5ufn5+np6evr6+zs7O3t7e7u7u/v7/Hx8fPz8/T09PX19fj4+P39/f7+/v//////////////
			/////////////////////////////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5
			BAEKAD8ALAAAAAAcABwAAAb+wB+FIikajZMKZXI8Jn8/C6aUcr1g2Kx2C3u5UqXLL5Jalc/mNHqt
			XkUerrh8Tq/THw67fh93NFosgIKBhIOGhSwNDCuMjY6PkI8MCyqVlpeYmZgLCimen6ChoqEKCSin
			qKmqq6oJCCewsbKztLMIBya5uru8vbwHBiXCw8TFxsUGCCTLzM3Oz84KDdDU1csQDyPa29zd3t14
			IuLj5OXm5X4h6uvs7e7tiiDy8/T19vWTH/r7/P3+/Zw8CBxIsKDBgqU4KFzIsKHDhq4eSpyo8JaH
			DhczYtyosSPHDsA0iBxJsqTJkgYOYMigYcOGkyNdamDZ8mUGDAd+FMhAEyYaSZ4/MxSA8oNAAABI
			kyINMEDAUaVJAxCAEgQAOw==
		}] \
		button-n [image create photo -data { \
			R0lGODlhHAAcAKU3AI2NjY6Ojo+Pj5CQkJGRkZOTk5SUlJeXl5mZmZubm52dnZ6enqCgoKKioqWl
			paenp6urq6ysrLCwsLGxsbKysrS0tLW1tba2tre3t7m5ubu7u9LS0tPT09TU1NXV1djY2NnZ2dra
			2tvb293d3d7e3uDg4OHh4eLi4uTk5OXl5efn5+jo6Onp6evr6+zs7O7u7vDw8PLy8vPz8/b29vf3
			9/39/f7+/v///////////////////////////////////yH5BAEKAD8ALAAAAAAcABwAAAb+wF+l
			MikajRRLhXI8Ui6/H0ajctFqtqx2y7XVaC5V5idxwczoszrNXsMkENpMTp/b6/j7DPLI+/V/Dw4y
			MYSGhYiHiokxDg0wkJGSk5STDQwvmZqbnJ2cDAsuoqOkpaalCwktq6ytrq+uCQgstLW2t7i3CAcr
			vb6/wMHABwYqxsfIycrJBggpz9DR0tPSCg4o2Nna29zbERAn4eLj5OXkfCbp6uvs7eyCJfHy8/T1
			9I4k+fr7/P38lyMCChxIsCBBUCISKlzIsCHDVCAiSpxIsSJFWR8yatzIsSPHXSJChBwpsiTJkyZD
			EOvAsqXLlzBfGjiggUMHDx5itsTZweYmzZwcNBz4UWCDT50uOWxIuqFAlB8EAgCYSnVqgAECpFal
			GoBAlCAAOw==
		}] \
		button-pa [image create photo -data { \
			R0lGODlhHAAcAMZIAFtzxF92xWB3xWh9x2h+x3aKzniLzpejzZWl2Jal2Zem2qSuzqSu0aSv0au0
			0LS70cHF0sjK09DS09LT1NPT1NLT19TU1NTV1tXV1NXV1dbW1tfX19DX7NjY19HY7NjY2NLY7dnZ
			2dva2Nvb29zc2d3d3d7e3uDg4Nvg8tvh8OHh4eLi4t7i8OTk5OXl5efn5+To8+jo6Onp6evr6+zs
			7O7u7vDw8PHx8fLy8vPz8/T08/L0+fT09PP0+PX19fX19vX19/f39vn49/r6+vv6+/v7+v79/v7+
			/v//////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH+
			EUNyZWF0ZWQgd2l0aCBHSU1QACwAAAAAHAAcAAAH/oBIKAoCAIaHiImJAgooggYeKTtGR5WWl5hH
			RjspHgWDICwwPURERUOoqaqoRaU9MCwchEC0Pz48uLm6uzw+P7RAhUJCQTo4x8jJysg6QcOGOTk4
			N9TV1tfXONGGNt3e3+Dh4IY15ebn6OnohjTt7u/w8fCGM/X29/j5+IYy/f7/AAMCNBSjoMGDCBMi
			BBDghcOHECNKjGjIhcWLGDNqzGiohcePIEOKDGlohcmTKFOqTGlIhcuXMGPKjGnohM2bOHPqzGnI
			hM+fQIMKDWqohNGjSJMqTWpohNOnUKNKjWoohNWrWLNqzWrog9evYMOKDWuIBAkRHTaoXcu27doO
			TCLMMqxA90IGDXjz6t2rIcMFuhUCJGjg4EGECRYyYLDAuLFjDBksTIjwwAGDBCgIHFgAQQIFx6BB
			U5AAYcGBAY5QIAigqHXrAAgcBQIAOw==
		}] \
		button-p [image create photo -data { \
			R0lGODlhHAAcAKUxAE9kqlNnq1ptrWd4s2h5s4GPvIKPvYOQvY6Xto6YtrW2t7e3uLa3u7i4uLq6
			uru7u7W7zba8zby8vLa8zr29vb6+vr+/vcDAwMHBwb7D0cPDw77D0sTExMbGxsfHx8nJycrKyszM
			zM3Nzc/Pz9HR0dLS0tPT09LU2NTU1NXV19jX19nZ2drZ2tra2d3c3d3d3d7e3v//////////////
			/////////////////////////////////////////////ywAAAAAHAAcAAAG/kDY5hAAGI/IZDJw
			2AgJkczJ9apar9iX65SJDIYTFqu1Kq/EZLN6vYIQU6i4fE6vy1NFVWnP7/v/fCpGJiSFhoeIiYYm
			RoqOj4VGI5OUlZaXlkYim5ydnp+eRiGjpKWmp6ZGIKusra6vrqqws7QgAAEfubq7vL28Rh7BwsPE
			xcRGHcnKy8zNzEYc0dLT1NXURhrZ2tvc3dzY3uHiGkYY5ufo6erpRhfu7/Dx8vFGFfb3+Pn6+UYU
			/v8AAwoMaESCwYMIEypMaMTCg4cQI0qcCNHCLQYOMmrcyLGjRgYBDCRoQLKkyZMoSyIwsEFASpML
			FLxsEFOAkw0FiijZqSRABAEnQQAAOw==
		}] \
		check-ac [image create photo -data { \
			R0lGODlhEAAQAIQeADdGdzlIeztKfz1Ngz5OhkBRikJTjUNUkF5jdFFkpFBlrGZmZmdnZ1Rnq1Vs
			uGhtfldtu1duu1duvFlvuFlvuVhvvVhvvllwv1lxwFpywltzxHx8fH19ffX19f///////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAV74CeOZDkuaKqiJ5IocAwnyCIuDSTt
			/A41ts/CkTkYj8aMI7iIaAydjgEq1USYzkJ02ylYmRINgcAdayRgzWDAXZ+ZFY2AGxVoKkyLJhAN
			8DsBGhZMFxoAh4iHGhdBDBMakJGSEwwiGw8UGJqbmhQPGyMcDCspDBwmqCUhADs=
		}] \
		check-au [image create photo -data { \
			R0lGODlhEAAQAIQZAIiIiJKSkZKSkpaWlpmZmZ2dnaCgoKGgn6GhoaSkpKmpqK6urrS0tL28utHR
			0dPT09bVz9ra2uTk5Ojm4+jn4+np6fHx8fr39fj4+P///////////////////////////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAVv4CeOZClCB6Cu7AGJB+I8dE07yCEG
			kVT9wJ8kEthJLJikMmmRFD+CCiZDrVIxFYFoILVasQMRoeu9VgiiArmMLYgMay/WIErEv5WESHGv
			YhV7fWaAFw0MSEtKFgwNFxcUDQuSk5QNExcfjpqbnB8hADs=
		}] \
		check-dc [image create photo -data { \
			R0lGODlhEAAQAIQcAF1qkV9rlGFtmGJvm2NwnWVyoGZ0o2d1pX2Bj3KCtYODg3KDvISEhHWEu3aI
			xoWJl3eJyHeKyHeKyXmLxniLynmLy3mMzHqNznqOz5WVlZaWlvf39z5Umz5Umz5Umz5UmyH5BAEK
			AB8ALAAAAAAQABAAAAV54CeOZDkqaKqiJ5IscAwniCIqDSTt/A41to/CcTkYj8aLI6iIYAybjQEq
			xUSYzkJ0uylYmRIMgcAdYyRgzGDAXZ+ZFIyAGxVgKHBMIBrYbwJ3TBUYAIWGhRgVQQwTGI6PkBMM
			IhkPExaYmZgTDxkjGgwrKQwaJqYlIQA7
		}] \
		check-du [image create photo -data { \
			R0lGODlhEAAQAIQZAIiIiJKSkZKSkpaWlpmZmZ2dnaCgoKGgn6GhoaSkpKmpqK6urrS0tL28utHR
			0dPT09bVz9ra2uTk5Ojm4+jn4+np6fHx8fr39fj4+P///////////////////////////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAVv4CeOZClCB6Cu7AGJB+I8dE07yCEG
			kVT9wJ8kEthJLJikMmmRFD+CCiZDrVIxFYFoILVasQMRoeu9VgiiArmMLYgMay/WIErEv5WESHGv
			YhV7fWaAFw0MSEtKFgwNFxcUDQuSk5QNExcfjpqbnB8hADs=
		}] \
		check-nc [image create photo -data { \
			R0lGODlhEAAQAIQeADdGdzlIeztKfz1Ngz5OhkBRikJTjUNUkF5jdFFkpFBlrGZmZmdnZ1Rnq1Vs
			uGhtfldtu1duu1duvFlvuFlvuVhvvVhvvllwv1lxwFpywltzxHx8fH19ffX19f///////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAV74CeOZDkuaKqiJ5IocAwnyCIuDSTt
			/A41ts/CkTkYj8aMI7iIaAydjgEq1USYzkJ02ylYmRINgcAdayRgzWDAXZ+ZFY2AGxVoKkyLJhAN
			8DsBGhZMFxoAh4iHGhdBDBMakJGSEwwiGw8UGJqbmhQPGyMcDCspDBwmqCUhADs=
		}] \
		check-nu [image create photo -data { \
			R0lGODlhEAAQAIQZAIiIiJKSkZKSkpaWlpmZmZ2dnaCgoKGgn6GhoaSkpKmpqK6urrS0tL28utHR
			0dPT09bVz9ra2uTk5Ojm4+jn4+np6fHx8fr39fj4+P///////////////////////////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAVv4CeOZClCB6Cu7AGJB+I8dE07yCEG
			kVT9wJ8kEthJLJikMmmRFD+CCiZDrVIxFYFoILVasQMRoeu9VgiiArmMLYgMay/WIErEv5WESHGv
			YhV7fWaAFw0MSEtKFgwNFxcUDQuSk5QNExcfjpqbnB8hADs=
		}] \
		check-pc [image create photo -data { \
			R0lGODlhEAAQAIQeADdGdzlIeztKfz1Ngz5OhkBRikJTjUNUkF5jdFFkpFBlrGZmZmdnZ1Rnq1Vs
			uGhtfldtu1duu1duvFlvuFlvuVhvvVhvvllwv1lxwFpywltzxHx8fH19ffX19f///////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAV74CeOZDkuaKqiJ5IocAwnyCIuDSTt
			/A41ts/CkTkYj8aMI7iIaAydjgEq1USYzkJ02ylYmRINgcAdayRgzWDAXZ+ZFY2AGxVoKkyLJhAN
			8DsBGhZMFxoAh4iHGhdBDBMakJGSEwwiGw8UGJqbmhQPGyMcDCspDBwmqCUhADs=
		}] \
		check-pu [image create photo -data { \
			R0lGODlhEAAQAIQeADdGdzlIeztKfz1Ngz5OhkBRikJTjUNUkF5jdFFkpFBlrGZmZmdnZ1Rnq1Vs
			uGhtfldtu1duu1duvFlvuFlvuVhvvVhvvllwv1lxwFpywltzxHx8fH19ffX19f///////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACH5BAEKAB8ALAAAAAAQABAAAAV24CeOZDkuaKqiJ5IocAwnyCIuDSTt
			/A41ts/CkTkYj8aMI7iIaAzQKFQTYToL2CyWypRoCOAwWCPpagboNJrMrGgE8DhcU2FaNIG8Pq+x
			MC8aAIKDghoXQQwTGouMjRMMIhsPFBiVlpUUDxsjHAwrKQwcJqMlIQA7
		}] \
		comboarrow-a [image create photo -data { \
			R0lGODlhEAAYAIQbAAAAAFtzxJem2sPDxcTDxcTExMjIycjJycrKysrKzMvLzM3Mzc/Pz8/P0NLS
			0t3d3d3d3uHh4eTk5efm5+jn6Ojo6Ojp6evr7Ovs6+zs7O/v7////////////////////ywAAAAA
			EAAYAAAFq2AgjiQpbIGGVVIEOQ6jLEYRCOnavvFcDyIVZeKCNRiJGiGIGRYdx2RhmdJMdjAGA2Ew
			UDVWbGzb/YafWq4BWL2iyeugxSJOIwpsVQXA7/PvNjkVE358CYBME0R+SAVdiUQPfFoJjgZBFxQt
			D1kKCAd4QRkWkVlbBzWipBGcY5+pKXMTEDwNCwmoebK0Rre5QRqrPGk1gWDCplwFxsFEw2TLwMiu
			qTgl1yInIQA7
		}] \
		comboarrow-d [image create photo -data { \
			R0lGODdhEAAYAIQZACAgIHCFzKSx38vLzMzLzMzMzM/P0M/Q0NHR0dHR0tLS0tPS09XV1dXV1tjY
			2OHh4eHh4uXl5efn6Orp6uvq6+vr6+vs7O7u7vHx8f///////////////////////////ywAAAAA
			EAAYAAAFp2AgjiQpZAF2VVIEOQ6jLEYRCOnavvFcDyIVZeKCNRiJGiF4GRYdx2RhmcJMdjAGA2Ew
			UDFWbGzb/YafWq4BWL2iyeugxSJOIwpsVQXA7/PvNjkVE358CYBME0R+SAVdiUQPfFoJjgZMFC0P
			WQoIB3hMFpFZWwc1oaNjnqcpcxMQPA0LCaZ5rrBGs7VBGKJvXAWBYL48aTXCvUTFZMG8xKTANyXT
			IychADs=
		}] \
		comboarrow-n [image create photo -data { \
			R0lGODlhEAAYAIQbAAAAAFtzxJem2sPDxcTDxcTExMjIycjJycrKysrKzMvLzM3Mzc/Pz8/P0NLS
			0t3d3d3d3uHh4eTk5efm5+jn6Ojo6Ojp6evr7Ovs6+zs7O/v7////////////////////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACwAAAAAEAAYAAAFq2AgjiQpbIGGVVIEOQ6jLEYRCOnavvFcDyIVZeKC
			NRiJGiGIGRYdx2RhmdJMdjAGA2EwUDVWbGzb/YafWq4BWL2iyeugxSJOIwpsVQXA7/PvNjkVE358
			CYBME0R+SAVdiUQPfFoJjgZBFxQtD1kKCAd4QRkWkVlbBzWipBGcY5+pKXMTEDwNCwmoebK0Rre5
			QRqrPGk1gWDCplwFxsFEw2TLwMiuqTgl1yInIQA7
		}] \
		comboarrow-p [image create photo -data { \
			R0lGODlhEAAYAIQbAAAAAFVsuI6czLe3ubi3ubi4uLu7vLu8vL29vb29v76+v8C/wMLCwsLCw8XF
			xc/Pz8/P0NPT09bW19nY2dnZ2dna2tzc3dzd3N3d3eDg4O/v7////////////////////yH+EUNy
			ZWF0ZWQgd2l0aCBHSU1QACwAAAAAEAAYAAAFpWAgjiQpaEF2UVIEOQ6jLEYRCOnavvFcDyIVZeKC
			NRiJGiG4IvKOycIylZnsYAwGwmCYZqrXmJbrBRfFWwOQaj1n0+tMpRJ+IwrxFWDP399tOUN9ewl/
			TBNEfUgFXIdED3tZCYwGQRYsEQ9YCggHeEEYFY9YWgc1oKKZpJ2nKXMTEE8LCaZxr7FGs7VBck6r
			NYBfqTxvwLzDvwXBvW5jNjgl0SInIQA7
		}] \
		combo-n [image create photo -data { \
			R0lGODlhGAAYAMIDAFtzxJem2u/r5////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1Q
			ACH5BAEKAAQALAAAAAAYABgAAAM/KAHc/hAsQau9WAAxuv9gOGxiKZJm2qGqybYnB5fv/NX2Kuf3
			zuu/XtCDyxVtx1kStmw1Vc9U1LQYdhSRbCQBADs=
		}] \
		combo-ra [image create photo -data { \
			R0lGODlhGAAYAMIDAFtzxJem2u/r5////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1Q
			ACH5BAEKAAQALAAAAAAYABgAAAM/KAHc/hAsQau9WAAxuv9gOGxiKZJm2qGqybYnB5fv/NX2Kuf3
			zuu/XtCDyxVtx1kStmw1Vc9U1LQYdhSRbCQBADs=
		}] \
		combo-rd [image create photo -data { \
			R0lGODlhGAAYAMIEAFNosomXxtnV0efn5////////////////yH5BAEKAAQALAAAAAAYABgAAAM/
			KAHc/hAsQau9WAAxuv9gOGxiKZJm2qGqybYnB5fv/NX2Kuf3zuu/XtCDyxVtx1kStmw1Vc9U1LQY
			dhSRbCQBADs=
		}] \
		combo-rf [image create photo -data { \
			R0lGODlhGAAYAMIEAE5jqIGOu83Jxtvb2////////////////yH5BAEKAAQALAAAAAAYABgAAANP
			KAHc/hAsQau9WAAxuv9gOGxiKZJjCqjs+qFm6HboHMvcDdq1fuY+2itnC46AQR7ROGSmPD3n0akU
			SmHJ5pMKXHlbLCjyOnYupB9FZB1JAAA7
		}] \
		combo-rn [image create photo -data { \
			R0lGODlhGAAYAMIEAE5jqIGOu83Jxtvb2////////////////yH5BAEKAAQALAAAAAAYABgAAAM/
			KAHc/hAsQau9WAAxuv9gOGxiKZJm2qGqybYnB5fv/NX2Kuf3zuu/XtCDyxVtx1kStmw1Vc9U1LQY
			dhSRbCQBADs=
		}] \
		combo-rp [image create photo -data { \
			R0lGODlhGAAYAMIEAEpdn3uHscK/vM/Pz////////////////yH5BAEKAAQALAAAAAAYABgAAAM/
			KAHc/hAsQau9WAAxuv9gOGxiKZJm2qGqybYnB5fv/NX2Kuf3zuu/XtCDyxVtx1kStmw1Vc9U1LQY
			dhSRbCQBADs=
		}] \
		progress-h [image create photo -data { \
			R0lGODlhMgAUAOcAAD5Umz5UnD9Umz9UnD5Vmz5VnD9Vmz9VnD9VnT9WnT9WnkBWnUBWnkBWn0FW
			nkBXnkFXnkFXn0FXoEJXoEJXoUFYn0FYoEFYoUJYoEJYoUNZokNZo0RZokJaokNaokNao0RaokRa
			o0RapERapURbpERbpUVbpEVbpUVcpEVcpUVcpkVcp0ZcpkZcp0dcp0VdpkZdpkZdp0ddp0ddqEde
			qEdeqUheqEheqUheqkdfqUdfqkhfqUhfqkhfq0lfqklfq0hgqkhgq0lgq0lgrEpgq0pgrEphrUph
			rkthrUthrkpirUpirktirUtirkxir0tjr0xjr0xjsE1jsExkr0xksE1ksU1ksk5ksU5ksk1lsU1l
			sk1ls05lsU5lsk5ms09ms09mtE9mtVBmtE9ntE9ntVBntFBntVBntlFntVFntlBotlBot1FotlFo
			t1FptlFpt1FpuFJpuFJpuVNpuVJquFJquVNquFNquVNqulNqu1RqulNrulNru1RrulRru1Nsu1Rs
			ulRsu1RsvVVsvFVsvVRtvFRtvVVtvFVtvVZtvVZuvlZuv1duv1duwFZvv1ZvwFdvv1dvwFhvwVdw
			wVhwwFhwwVhwwllwwVhxwVlxw1lxxFpxw1pxxFlyw1lyxFpyw1pyxD5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5UmyH5BAEKAP8ALAAAAAAyABQA
			AAj+AEEJHEiwoMGDCBMa/PSJEydQnwR+0sQQVKdMmUB54pTJEyiHmzZ56hRyo6ZNJEN2uphp5cpM
			KC1hqoTpUiVLlXJWsilTp6WflyTpHIqzktChQ4VSEjpJUqRIkBY1gvRoEaSrkao6YgSJkaOtVrtG
			XcSoLCRFZReRZbRI0SKwaNsqSoSort26dBHRPUToLqG+g/r+JTRoECJChg4fPjToEN/DggYVInTI
			j2U+fgLx4RPIDyA+ff5c7uOHD6A+pPf0UY25NGnUqPngWd0nD2w9fPLUqTOHjpw4dOrcsbO7Tpzf
			ceLUoUMnjh3mcoInj94cuPLkyqsDhxMHjhs1b97+sGGzhk2b8mvSr1Fjnn0bNmnYj1dzRj4b+WrY
			11eT5gz8M2gASMYYZoBhoBhljBEGgmOMYSAYYjwooYMGfvHgGBaCkeGDX3TohRcaWtHFiFhssYUW
			WHShBYlaiHiFilmkyIUWWdCIhRUtyqjFFVrMqIUWVVxhhRVVZDFjFFRMIUUUUUDBpBROMhnFFE0m
			2eSVTTqpJRRcdumkE044+cQTUYDpRBJNpKkEE0skkcQRbCaBhBFMuMlEnUooIScSSBxhxJ9/3vmn
			EoPyaQShgBoxBBFCCDFEEY1G2iijizoqBKOSZirED5o2+kMQPPggRBBA9CDEDjfcgAMONax6Qw7+
			NaSqg6qv3rBDDqnGeoMNNdCQA66xBktDDbHSkGuqvNYQwwwxNCuDC83GIEOzLcRQbbTRtsBCC9fG
			AEOzLLCgQgswsEBtuOHCsEILL5RQwgklpACvCSfAiwK9J9D7LgnvnsCvuybw6y+8JZBg8LwmjCCC
			CSYsbDAHG2zwQQgSe7BBCCB84IHGG2jAscYaRKyBBh6MHHLIHXxg8sosj5xBBhdYgAEGF2Qw88wZ
			WEABBjDTfLPMQFsgMwZCT4CBBEQjHYHMSEtQgdEPPOAAAxBIDUEDDGTNwANad7111lwnsAADCyyg
			gAJkdz121gkkkDYCBRwQ9wABHGC33XHLTUAiAXUbMMAAAAQwQAGECy74AQEEToABAAhQgN+BD0CA
			5AAEBAA7
		}] \
		progress-v [image create photo -data { \
			R0lGODlhFAAyAOcAAD5Umz5UnD9Umz9UnD5Vmz5VnD9Vmz9VnD9VnT9WnT9WnkBWnUBWnkBWn0FW
			nkBXnkFXnkFXn0FXoEJXoEJXoUFYn0FYoEFYoUJYoEJYoUNZokNZo0RZokJaokNaokNao0RaokRa
			o0RapERapURbpERbpUVbpEVbpUVcpEVcpUVcpkVcp0ZcpkZcp0dcp0VdpkZdpkZdp0ddp0ddqEde
			qEdeqUheqEheqUheqkdfqUdfqkhfqUhfqkhfq0lfqklfq0hgqkhgq0lgq0lgrEpgq0pgrEphrUph
			rkthrUthrkpirUpirktirUtirkxir0tjr0xjr0xjsE1jsExkr0xksE1ksU1ksk5ksU5ksk1lsU1l
			sk1ls05lsU5lsk5ms09ms09mtE9mtVBmtE9ntE9ntVBntFBntVBntlFntVFntlBotlBot1FotlFo
			t1FptlFpt1FpuFJpuFJpuVNpuVJquFJquVNquFNquVNqulNqu1RqulNrulNru1RrulRru1Nsu1Rs
			ulRsu1RsvVVsvFVsvVRtvFRtvVVtvFVtvVZtvVZuvlZuv1duv1duwFZvv1ZvwFdvv1dvwFhvwVdw
			wVhwwFhwwVhwwllwwVhxwVlxw1lxxFpxw1pxxFlyw1lyxFpyw1pyxD5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5U
			mz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5Umz5UmyH5BAEKAP8ALAAAAAAUADIA
			AAj+AAs8yMChRIwdQ5JEsULGTR0/iSJZAgXqwMANJWbcINKESpcxah4iioTpE6gCDi5sOBHjhpAm
			U7qYeTPHDyJIlUweYGDhg0EcL6V0AfOGDh9EizBxAjUAAoYQKWLgGKIkChYwbOTYbHRpaYAHGFbK
			qFGESZQtWOMEulmJ4oGUPl0AXQJli5g1RhE9sqQTQgYPJqQKUailDJs6Rxe1rdggLEuXCrGMaXNn
			LU63DJ6yzCHkiNAwa+xAxKkzM4gSY4UwgaJFzGFAbDWdzPwBRUshS6J0KbMG8chLpf8Ghqx7TO8+
			iR7lrPig54kWOoggsWo8zh+kE2dT8PBYiJEoWsD+rNF6yBGmTqAIZN5gosVUJlOsgFETxw8hRpUy
			zc6g4TERhUOxEcdROOkXAAMX+BQDZ0lAcYUYbcTRByL4YYYBdy0NwYRH84nkiCWegGIAghuQcJBq
			U4THRl4fLjUAbQbl8F8UWYDRBh2A3GeJfi9e2J0SUFwlYB+ELHJJiACA1d9tVQ2Vhh0TQiIJRQda
			UGILNQwGBRfz0eHHIDi5uF4JLLg0nYp07HFfJUsJZIEGJbRgJo1jZBVlJZvMhgGcLdggBBKsYZVm
			kXielIAFgMWQ5RFQ1BgSkYqFGMACb5pIg3dWgXHGgGui9+KbMXoHhRVf0PclfnlOuucJMHD2nYr+
			Wg3CiCV5DrBAWCa6ZMSoghJYSYgHKPAmSzX8sKuQdBCpCJugBCAsRmWqBsVHphrCiCSyAcDABB2Q
			meVqXHwxJIWFqvoBCSroGuiKkFaCnnoSaEAClqJeMZ+ESBU64p4kwHApkFqUWgeRqIKi7bAsZLkr
			lwLycUjBAjAQr0EKg6dpHHgMohh6BdyqwXBCKOFEePT1cciy6I0Ywcct0PADEiN3uMchivHIkwYj
			lBkEoFWAkUayhDiSn8GZaSBCmTx8d8UXm+ZBoSToBZBAvCYk7IMST5A6JKGeJrBn1bpm/UUaEgqi
			CCXvSmw0DDcE8V0VXpyRrKxQM7VABR+vYAMsEEY4kYUXaMChRyE1p7etvFj20DeXm/JBiCKT5AkA
			Avy+oPDIXwSex8l1BwQAOw==
		}] \
		radio-ac [image create photo -data { \
			R0lGODlhEAAQAMZBADtKfz9OgUBQiUFSjERVkkVXlUZYk0ZYl0ldnktfoVJlpFZlmWVmaWRmbGVm
			a15mg2ZnamZna2ZnbmZoamZobWdoa2dobFdooGlqbWFqh2FqiGJqh1RqtWlrcVlrpVtsolxso1xt
			pFhtsVZtuFltsW1udFxuqVZuu1duu1duvFpvtFhvvVlwv1lxwVpxwVpywlpyw3BzeVtyw1tzw4OE
			hoqKi4GKqYKLrIWPs4aRtbKysre3t8/S3M/T3tDT3tDU4PX19f//////////////////////////
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH+
			EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQABAAAAe0gH+Cg4SFhn8SDAwSh4MODwsK
			CgsPDocNFxwjJycjHBcNhRAeKykJBQUJKSseEIMTGisrBjk/PzkGshoTgh0fLgg4QMNAOAguHx2C
			ESIwAz7EQD4DMCIRghUkMgI90T0CMiQVgjEgLwc30TcHLyAxgjQbLCgBNjw8NgEoLBs0gxgmXKAg
			AAAAARQuTGAgpIOCiRYvZsx40cIEBR2FdljIEEKFihAZLOxoVKMEBAglajRaSSgQADs=
		}] \
		radio-au [image create photo -data { \
			R0lGODlhEAAQAKU6AIqJiYqKioyLi4+Pj5ORkZOTk5WVlJWVlZeXl5ubm5ybm56dnZ6enp+fn6mp
			qaqpqayrq6ysrK2tra+vr7CwsLOzs7S0tLu6usDAwMLCwsPCwMTDwcjIyMnJycvLy83NzdHR0dLR
			0NnY1tvZ2NzZ2N3b2tzc3N3d3d/f3+Tk5Ofn5+jo6Onp6ezs7PDt7PPx7vLy8vb29vn39fn49Pz3
			9/r49fn5+fv7+/z8/P7+/v///////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5
			BAEKAD8ALAAAAAAQABAAAAacwJ9wSCwaC4IAQEAwDgcSDgjUmQyciA5q1WqtUJ1D0fBRwWy3mw2m
			8hiGEYsqhsvpdDlcTFWBCBcgMDh3hDo4MCAMQgopNnaFeDYpCT8yDSw3kIQ3Kw0yPw8nmZo6NyYO
			QhoZjpo5NhgbQi4OKYOQOCkOLkMiEip1d3kqEiRENCNRKzY2KxwUJTRFMi8hFxMTFyEvn04zNd81
			M0VBADs=
		}] \
		radio-dc [image create photo -data { \
			R0lGODlhEAAQAMZAAFRhj1dlkVhmmFlom1xroF1so15toV5tpGByqmJzrXl5fHh5f2h5sHl5fmx5
			pnN5k3l6fXl6fnl6gHl7fXl7gHp7fnp7f2x7rHx9gHV9lnV9l3Z9lmp9vnx+g25+sHB/rnF/r22A
			u3GAsG6Au4CAhmyAwXGAtGyAxGyAxW+Bvm2BxW6Cx26DyW+DyW+Eym+Ey4KFinCEy3CFy5OUlZmZ
			mpGZtJKat5WdvZWfvry8vMDAwNXY4NXZ4tbZ4tbZ5Pb29v//////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAEAALAAAAAAQABAAAAe0gECCg4SFhkASCgoSh4MNDw4MDA4PDYcLFxwlJyclHBcLhRAeKigJ
			BQUJKCoeEIMTGioqBjg+PjgGshoTgh0fLQg3P8M/NwgtHx2CESEvAz3EPz0DLyERghUjMQI80TwC
			MSMVgjAgLgc20TYHLiAwgjMbKycBNTs7NQEnKxszgxgmWpwgAAAAgRMtTGAglIOCCRYuZMhwwcIE
			hRyFdFjIICJFChEZLOhoRIMEBAgkaDRaSSgQADs=
		}] \
		radio-du [image create photo -data { \
			R0lGODlhEAAQAKU6AIqJiYqKioyLi4+Pj5ORkZOTk5WVlJWVlZeXl5ubm5ybm56dnZ6enp+fn6mp
			qaqpqayrq6ysrK2tra+vr7CwsLOzs7S0tLu6usDAwMLCwsPCwMTDwcjIyMnJycvLy83NzdHR0dLR
			0NnY1tvZ2NzZ2N3b2tzc3N3d3d/f3+Tk5Ofn5+jo6Onp6ezs7PDt7PPx7vLy8vb29vn39fn49Pz3
			9/r49fn5+fv7+/z8/P7+/v///////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5
			BAEKAD8ALAAAAAAQABAAAAacwJ9wSCwaC4IAQEAwDgcSDgjUmQyciA5q1WqtUJ1D0fBRwWy3mw2m
			8hiGEYsqhsvpdDlcTFWBCBcgMDh3hDo4MCAMQgopNnaFeDYpCT8yDSw3kIQ3Kw0yPw8nmZo6NyYO
			QhoZjpo5NhgbQi4OKYOQOCkOLkMiEip1d3kqEiRENCNRKzY2KxwUJTRFMi8hFxMTFyEvn04zNd81
			M0VBADs=
		}] \
		radio-nc [image create photo -data { \
			R0lGODlhEAAQAMZBADtKfz9OgUBQiUFSjERVkkVXlUZYk0ZYl0ldnktfoVJlpFZlmWVmaWRmbGVm
			a15mg2ZnamZna2ZnbmZoamZobWdoa2dobFdooGlqbWFqh2FqiGJqh1RqtWlrcVlrpVtsolxso1xt
			pFhtsVZtuFltsW1udFxuqVZuu1duu1duvFpvtFhvvVlwv1lxwVpxwVpywlpyw3BzeVtyw1tzw4OE
			hoqKi4GKqYKLrIWPs4aRtbKysre3t8/S3M/T3tDT3tDU4PX19f//////////////////////////
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH+
			EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQABAAAAe0gH+Cg4SFhn8SDAwSh4MODwsK
			CgsPDocNFxwjJycjHBcNhRAeKykJBQUJKSseEIMTGisrBjk/PzkGshoTgh0fLgg4QMNAOAguHx2C
			ESIwAz7EQD4DMCIRghUkMgI90T0CMiQVgjEgLwc30TcHLyAxgjQbLCgBNjw8NgEoLBs0gxgmXKAg
			AAAAARQuTGAgpIOCiRYvZsx40cIEBR2FdljIEEKFihAZLOxoVKMEBAglajRaSSgQADs=
		}] \
		radio-nu [image create photo -data { \
			R0lGODlhEAAQAKU6AIqJiYqKioyLi4+Pj5ORkZOTk5WVlJWVlZeXl5ubm5ybm56dnZ6enp+fn6mp
			qaqpqayrq6ysrK2tra+vr7CwsLOzs7S0tLu6usDAwMLCwsPCwMTDwcjIyMnJycvLy83NzdHR0dLR
			0NnY1tvZ2NzZ2N3b2tzc3N3d3d/f3+Tk5Ofn5+jo6Onp6ezs7PDt7PPx7vLy8vb29vn39fn49Pz3
			9/r49fn5+fv7+/z8/P7+/v///////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5
			BAEKAD8ALAAAAAAQABAAAAacwJ9wSCwaC4IAQEAwDgcSDgjUmQyciA5q1WqtUJ1D0fBRwWy3mw2m
			8hiGEYsqhsvpdDlcTFWBCBcgMDh3hDo4MCAMQgopNnaFeDYpCT8yDSw3kIQ3Kw0yPw8nmZo6NyYO
			QhoZjpo5NhgbQi4OKYOQOCkOLkMiEip1d3kqEiRENCNRKzY2KxwUJTRFMi8hFxMTFyEvn04zNd81
			M0VBADs=
		}] \
		radio-pc [image create photo -data { \
			R0lGODlhEAAQAMZBADtKfz9OgUBQiUFSjERVkkVXlUZYk0ZYl0ldnktfoVJlpFZlmWVmaWRmbGVm
			a15mg2ZnamZna2ZnbmZoamZobWdoa2dobFdooGlqbWFqh2FqiGJqh1RqtWlrcVlrpVtsolxso1xt
			pFhtsVZtuFltsW1udFxuqVZuu1duu1duvFpvtFhvvVlwv1lxwVpxwVpywlpyw3BzeVtyw1tzw4OE
			hoqKi4GKqYKLrIWPs4aRtbKysre3t8/S3M/T3tDT3tDU4PX19f//////////////////////////
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH+
			EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQABAAAAe0gH+Cg4SFhn8SDAwSh4MODwsK
			CgsPDocNFxwjJycjHBcNhRAeKykJBQUJKSseEIMTGisrBjk/PzkGshoTgh0fLgg4QMNAOAguHx2C
			ESIwAz7EQD4DMCIRghUkMgI90T0CMiQVgjEgLwc30TcHLyAxgjQbLCgBNjw8NgEoLBs0gxgmXKAg
			AAAAARQuTGAgpIOCiRYvZsx40cIEBR2FdljIEEKFihAZLOxoVKMEBAglajRaSSgQADs=
		}] \
		radio-pu [image create photo -data { \
			R0lGODlhEAAQAMZBADtKfz9OgUBQiUFSjERVkkVXlUZYk0ZYl0ldnktfoVJlpFZlmWVmaWRmbGVm
			a15mg2ZnamZna2ZnbmZoamZobWdoa2dobFdooGlqbWFqh2FqiGJqh1RqtWlrcVlrpVtsolxso1xt
			pFhtsVZtuFltsW1udFxuqVZuu1duu1duvFpvtFhvvVlwv1lxwVpxwVpywlpyw3BzeVtyw1tzw4OE
			hoqKi4GKqYKLrIWPs4aRtbKysre3t8/S3M/T3tDT3tDU4PX19f//////////////////////////
			////////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH+
			EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAH8ALAAAAAAQABAAAAeygH+Cg4SFhn8SDAwSh4MODwsK
			CgsPDocNFxwjJycjHBcNhRAeKykJBQUJKSseEIMTGisrBjmoOQayGhOCHR8uCDgywjI4CC4fHYIR
			IjADBcMyBQMwIhGCFSQyAs/DBQIyJBWCMSAvBzfQNwcvIDGCNBssKAE2qDYBKCwbNIMYJi4oCAAA
			QACFCxMYCOmgYKLFixkzXrQwQUFHoR0WMoRQoSJEBgs7GtUoAQFCiRqNUhIKBAA7
		}] \
		sbthumb-ha [image create photo -data { \
			R0lGODlhIAAMAKU4AIKBgYODg4aGhYiIiIqKioyMi5SUlJeXl5mampucnJ6en6CgoLKzs7OzsrW0
			tbS1tbW1tLW1tbe3t7m5ubu7u7y7u7y7vLu8u7u8vLy8u76+v8DAwMHAwMHAwcDBwMHBwcvLy8vL
			zMvMy8/Pz9LS0tPS0tLT0tPT0tTU1NbV1tbW1dbW1tnZ2trZ2drZ2tna2dna2tra2dzb3Nzc29zc
			3ODh4OPj4+Xk5f///////////////////////////////yH5BAEKAD8ALAAAAAAgAAwAAAa/wJ9w
			SCwaj8SFrCajOWey5owGnT5lVlpTC70lUquwOKUKo1JolGotVqHEYhuiRCKhUHWT3o4q0e0kfnWD
			hDUHIyMiJCKIjYt1jIkkiJMjj5YjNQYhIiIgISChoqKgoJ+eo6ciMgQarq+wGbCztK8ZKwMYFhUU
			vBUXFBcZFMS9FRUZx8QYF83EFSsCFBPFE9QS1cTW08Xc1NS3AhEREhLj5eTjERPn5urp6RMSKgAN
			9vf4DQwMDvn++SeQCBxYJAgAOw==
		}] \
		sbthumb-hd [image create photo -data { \
			R0lGODlhIAAMAKU2AKyrq62tra+vrrGxsbOzs7S0s7q6ur29vb6/v8DAwMLCw8TExNLT09PT0tTT
			1NPU1NTU09TU1NXV1tbW1djY2NnZ2drZ2drZ2tna2dna2tra2dvb3N3d3d7d3d7d3t3e3d7e3ubm
			5ujo6Ono6Ojp6Onp6Ovr6+zr6+vs6+zs6+3t7e7u7vDw8fHw8PHw8fDx8PDx8fHx8PPz8/b39vj4
			+Pr5+v///////////////////////////////////////yH5BAEKAD8ALAAAAAAgAAwAAAarwJ9w
			SCwaj8SFbCZrOp/QqLSWWFmv2JXqus1qvTTEyWRSqciodFl1GpdNbbJ8PjuMRiFTiMQXifRkISMi
			eXcmIyWAIyYiMwYhkJGSk5SVkDIEG5qbnBqcn6CbGisDGRcWFagWGBUYGhWwqRYWGrOwGRi5sBYr
			AhUUsRTAE8Gwwr+xyMDAowIRERMTz9HQzxEU09LWERLT1xMrAA3j5OUNDAwO5uvmKUjv8EVBADs=
		}] \
		sbthumb-hn [image create photo -data { \
			R0lGODlhIAAMAMZgAI2MjI6OjpGRkJSUlJaWlpiYl6CgoKSkpKanp6ipqaurrK6ursHBwcLBwcHC
			wcLCwcHBwsLBwsHCwsTEw8TDxMPExMTExMbGxsfGxsbHxsfHxsbGx8fGx8bHx8fHx8nJycvLy8zL
			y8vMy8zMy8vLzMzLzMvMzMzMzM7Ozs/Ozs7Oz9DQ0NHQ0NDR0NHR0NDQ0dHQ0dDR0dHR0dzc3N3c
			3Nzd3Nzc3d3c3eDg4OHg4ODh4OHh4OHg4eDh4eHh4eTk5OXk5OTl5OXl5OXk5eTl5ebm5ufn5+jn
			5+jo5+jn6Ojo6Onp6erq6uvr6+zr6+vs6+zs6+vr7Ozr7Ovs7Ozs7O/u7u/v7u/u7+7v7+/v7/Dw
			8PHx8fP08/X19fb29vj3+P//////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAgAAwAAAfWgH+Cg4SFhoeEC1dcV1mOVleNVlmQk49XllmNmpBfCUlKoaJJSKFF
			SahFSKuiSEWiol4IQD8/RUW1Qbq2RUC0tj++tcPEXAc5OTU/NTrNODjLtTU5OMrIPzk70Tk/OFwG
			NjU1MzYz5ufn5eXk4+jsNVcEKvP09SP1+Pn0I0oDJiUhQAQMIQKEiBEgEgoMEWIEw4QmREhMGEKJ
			ABAfFH7IqEFjwo0YFYbMmJGfAAsWNGhAqTIlSgsfWK58aWEDS5gakAB4wLOnzwcSJFD4SfSnEERI
			kxYKBAA7
		}] \
		sbthumb-hp [image create photo -data { \
			R0lGODlhIAAMAKU4AIKBgYODg4aGhYiIiIqKioyMi5SUlJeXl5mampucnJ6en6CgoLKzs7OzsrW0
			tbS1tbW1tLW1tbe3t7m5ubu7u7y7u7y7vLu8u7u8vLy8u76+v8DAwMHAwMHAwcDBwMHBwcvLy8vL
			zMvMy8/Pz9LS0tPS0tLT0tPT0tTU1NbV1tbW1dbW1tnZ2trZ2drZ2tna2dna2tra2dzb3Nzc29zc
			3ODh4OPj4+Xk5f///////////////////////////////yH5BAEKAD8ALAAAAAAgAAwAAAa/wJ9w
			SCwaj8SFrCajOWey5owGnT5lVlpTC70lUquwOKUKo1JolGotVqHEYhuiRCKhUHWT3o4q0e0kfnWD
			hDUHIyMiJCKIjYt1jIkkiJMjj5YjNQYhIiIgISChoqKgoJ+eo6ciMgQarq+wGbCztK8ZKwMYFhUU
			vBUXFBcZFMS9FRUZx8QYF83EFSsCFBPFE9QS1cTW08Xc1NS3AhEREhLj5eTjERPn5urp6RMSKgAN
			9vf4DQwMDvn++SeQCBxYJAgAOw==
		}] \
		sbthumb-va [image create photo -data { \
			R0lGODlhDAAgAKU4AIKBgYODg4aGhYiIiIqKioyMi5SUlJeXl5mampucnJ6en6CgoLKzs7OzsrW0
			tbS1tbW1tLW1tbe3t7m5ubu7u7y7u7y7vLu8u7u8vLy8u76+v8DAwMHAwMHAwcDBwMHBwcvLy8vL
			zMvMy8/Pz9LS0tPS0tLT0tPT0tTU1NbV1tbW1dbW1tnZ2trZ2drZ2tna2dna2tra2dzb3Nzc29zc
			3ODh4OPj4+Xk5f///////////////////////////////yH5BAEKAD8ALAAAAAAMACAAAAbDwN/N
			VqvJVkjV6fc7kkaiTCUjaTBnKxJJpKFQJtZmdhTqTiJhWpYE0lwoVaZ6276cw062m4KWo55tGBNx
			PzQqgF18aWttXn0/WCVQGhWKTEeSZZWPM4d6GXdyKigibZWEhk+ag2l/I6ahkCklImWOeLN6XhMO
			Vyl/jWcMfqSNfMOQjBkZloUrJq97hDIq0I0SjzIp1tJhWIgVrHJjwY9qpJrN57pweFkiXKdhNWNc
			FrHamRoYzQsJCAcMEBggQACAH0EAADs=
		}] \
		sbthumb-vd [image create photo -data { \
			R0lGODlhDAAgAKU2AKyrq62tra+vrrGxsbOzs7S0s7q6ur29vb6/v8DAwMLCw8TExNLT09PT0tTT
			1NPU1NTU09TU1NXV1tbW1djY2NnZ2drZ2drZ2tna2dna2tra2dvb3N3d3d7d3d7d3t3e3d7e3ubm
			5ujo6Ono6Ojp6Onp6Ovr6+zr6+vs6+zs6+3t7e7u7vDw8fHw8PHw8fDx8PDx8fHx8PPz8/b39vj4
			+Pr5+v///////////////////////////////////////yH5BAEKAD8ALAAAAAAMACAAAAauwF+N
			NpvJVshV6vc7mkQhjUUzaTCdptCmUqFYmyvTSNuNfLFaTKV6DYfSFHPblN2o5U2VqaTNUCRnYWNb
			FXhohIYrJ4MWhYGLWo2JdFoacYEqbxuNbGBPkRSdMnqMl20nmlyJJ3VcFA5temRxDFcqmWSFtZ5Z
			GhqObShQdmuBwmQTiSgkacVzzJuhgSbQZZiakpitzp7Y3DOCWhemYJAbGcA/CwkIBwYEAwICAD9B
			ADs=
		}] \
		sbthumb-vn [image create photo -data { \
			R0lGODlhDAAgAMZhAI2MjI6OjpGRkJKSkpSUlJaWlpiYl6CgoKSkpKanp6ipqaurrK6ursHBwcLB
			wcHCwcLCwcHBwsLBwsHCwsTEw8TDxMPExMTExMbGxsfGxsbHxsfHxsbGx8fGx8bHx8fHx8nJycvL
			y8zLy8vMy8zMy8vLzMzLzMvMzMzMzM7Ozs/Ozs7Oz9DQ0NHQ0NDR0NHR0NDQ0dHQ0dDR0dHR0dzc
			3N3c3Nzd3Nzc3d3c3eDg4OHg4ODh4OHh4OHg4eDh4eHh4eTk5OXk5OTl5OXl5OXk5eTl5ebm5ufn
			5+jn5+jo5+jn6Ojo6Onp6erq6uvr6+zr6+vs6+zs6+vr7Ozr7Ovs7Ozs7O/u7u/v7u/u7+7v7+/v
			7/Dw8PHx8fP08/X19fb29vj3+P//////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH5
			BAEKAH8ALAAAAAAMACAAAAfegH9gX11dWEuISUN/f4dAOTYkIiQbEIxXS0BANishISCWjZk6N50g
			F6FamUA0KyMhlYyqm60jp6GOrK4hqLJGQDytJyAcqUlAOq2evX+zusuhmEE6nCK8uEvTpdbMV8e6
			JLeySUY2rdaxzcc52yDpWr/JKyLif1dKQTal0IxY+M+fKlxS8kvZqQm+yinjhdDeKhokSFyTtURI
			jlqwcCWxqGwDM39CdmBMhwmIyHnuUmU6+YmZqnLbJjZbUrBTxn6ZbFS7+afLKE4m6vnTtuKETAYK
			EiA4UICAAAEA/gQCADs=
		}] \
		sbthumb-vp [image create photo -data { \
			R0lGODlhDAAgAKU4AIKBgYODg4aGhYiIiIqKioyMi5SUlJeXl5mampucnJ6en6CgoLKzs7OzsrW0
			tbS1tbW1tLW1tbe3t7m5ubu7u7y7u7y7vLu8u7u8vLy8u76+v8DAwMHAwMHAwcDBwMHBwcvLy8vL
			zMvMy8/Pz9LS0tPS0tLT0tPT0tTU1NbV1tbW1dbW1tnZ2trZ2drZ2tna2dna2tra2dzb3Nzc29zc
			3ODh4OPj4+Xk5f///////////////////////////////yH5BAEKAD8ALAAAAAAMACAAAAbDwN/N
			VqvJVkjV6fc7kkaiTCUjaTBnKxJJpKFQJtZmdhTqTiJhWpYE0lwoVaZ6276cw062m4KWo55tGBNx
			PzQqgF18aWttXn0/WCVQGhWKTEeSZZWPM4d6GXdyKigibZWEhk+ag2l/I6ahkCklImWOeLN6XhMO
			Vyl/jWcMfqSNfMOQjBkZloUrJq97hDIq0I0SjzIp1tJhWIgVrHJjwY9qpJrN57pweFkiXKdhNWNc
			FrHamRoYzQsJCAcMEBggQACAH0EAADs=
		}] \
		scale-ha [image create photo -data { \
			R0lGODdhIAAPAKUwAFtzxJem2rKyssHCwsLCwcTDxMPExMTEw8TExMbGx8fHxsnJycvLy8zLy8zL
			zMvMy8vMzMzMy87Oz9DQ0NHQ0NHQ0dDR0NHR0dzc3Nzc3dzd3ODg4OHg4ODh4OHh4OTk5OXk5OTl
			5Obm5ujn6Ojo5+jo6Ovr7Ozr6+zr7Ovs6+vs7Ozs6+/u7+/v7u/v7/P08///////////////////
			/////////////////////////////////////////////ywAAAAAIAAPAAAG/kBYAEAsGo/IZEAI
			eLFc0Bbr2XJJq1EW1vXktgBDU0msYqVSrJLqxDaxxNMS6lRa2U8rFXFU6vtHJH0iI4QiJId+JCJ+
			fkQgHx8iIpAhlZEiII+RH5mQnp9EHBwaHxodpxsbHwKQAhwbrKIfHB6lsx8bRBkaGhgZGMDBAsDD
			GcW9wcC7GkQXzhYVFs4TEhMCFxUCFBbXEhcTFOEUExUVF0QS6errEQLp7hLw6/MRRBAODQz5DQ8M
			D+0MGAho0EBABIIBITxYGLABEQYLAkKMqEBixIkQJWaMGLEeAAQIFCgAKTIkSAQLSI48iSABSZQK
			iBgwUABkzQI0C+jUeeAkHM6dM3cWAAOAgNGjSAcMKIC0qVMwTJJInVpkSRAAOw==
		}] \
		scale-hd [image create photo -data { \
			R0lGODdhIAAPAKUmAHCFzKSx37y8vMnKysrKyczLzMvMzMzMy8zMzM3Nzs7OzdDQ0NLS0tTU1dbW
			1tfW1tfW19bX1tfX1+Dg4ODg4eDh4OTk5OXk5OTl5OXl5Ofn5+jn5+fo5+np6evq6+vr6uvr6+7u
			7vHw8fHx8PHx8fX19f//////////////////////////////////////////////////////////
			/////////////////////////////////////////////ywAAAAAIAAPAAAG/kBTAEAsGo/IZEAI
			KIlI0JHoOSJJq1ERlvTkjgDDEEgcEoXK4/PZDJqm0+oQ0QOq2z2fesfD73z+dh8ddnZEGxoaHR2I
			HI2JHRuHiRqRiJaXRBcXFRoVGJ8WFhoCiAIXFqSaGhcZnasaFkQUFRUTFBO4uQK4uxS9tbm4sxVE
			EsYREBHGDg0OAhIQAg8Rzw0SDg/ZDw4QEBJEDeHi4wwC4eYN6OPrDEQM7/Dx5e8C9PL37QAMC/AL
			/Ar93vnbF4+fwXdEECBQoEAhw4UKESxw2DAiggQOJSogYsBAAYUfC3gsQJLkgYgiS3YsWQAMAAIw
			Y8ocMKCAzJs4wTBJwrNnBJElQQAAOw==
		}] \
		scale-hn [image create photo -data { \
			R0lGODdhIAAPAKUwAFtzxJem2rKyssHCwsLCwcTDxMPExMTEw8TExMbGx8fHxsnJycvLy8zLy8zL
			zMvMy8vMzMzMy87Oz9DQ0NHQ0NHQ0dDR0NHR0dzc3Nzc3dzd3ODg4OHg4ODh4OHh4OTk5OXk5OTl
			5Obm5ujn6Ojo5+jo6Ovr7Ozr6+zr7Ovs6+vs7Ozs6+/u7+/v7u/v7/P08///////////////////
			/////////////////////////////////////////////ywAAAAAIAAPAAAG/kBYAEAsGo/IZEAI
			eLFc0Bbr2XJJq1EW1vXktgBDU0msYqVSrJLqxDaxxNMS6lRa2U8rFXFU6vtHJH0iI4QiJId+JCJ+
			fkQgHx8iIpAhlZEiII+RH5mQnp9EHBwaHxodpxsbHwKQAhwbrKIfHB6lsx8bRBkaGhgZGMDBAsDD
			GcW9wcC7GkQXzhYVFs4TEhMCFxUCFBbXEhcTFOEUExUVF0QS6errEQLp7hLw6/MRRBAODQz5DQ8M
			D+0MGAho0EBABIIBITxYGLABEQYLAkKMqEBixIkQJWaMGLEeAAQIFCgAKTIkSAQLSI48iSABSZQK
			iBgwUABkzQI0C+jUeeAkHM6dM3cWAAOAgNGjSAcMKIC0qVMwTJJInVpkSRAAOw==
		}] \
		scaletrough-h [image create photo -data { \
			R0lGODlhIAAPAIQUAL6+vr++vr++v76/vr6/v7+/vsHBwsPDw8TDw8TDxMPEw8TExM7Ozs7Oz87P
			ztLS0tPS0tLT0tPT0tbW1v///////////////////////////////////////////////yH5BAEK
			AB8ALAAAAAAgAA8AAAVx4CeOZGmeaKqubOu+cHxCtDM5Uf4893RDDxttApH0IJNdo+FwMBqMqFQK
			hT6d02tzwV0oEgruwXBILBIJRHhhWBwQcETZzDbY7/gCfs+/FwoEBAIBAIQBAwADBQCMhQEBBY+M
			BAOVjI8ymZqbnJ2eLSEAOw==
		}] \
		scaletrough-v [image create photo -data { \
			R0lGODlhDwAgAIQUAL6+vr++vr++v76/vr6/v7+/vsHBwsPDw8TDw8TDxMPEw8TExM7Ozs7Oz87P
			ztLS0tPS0tLT0tPT0tbW1v///////////////////////////////////////////////yH5BAEK
			AB8ALAAAAAAPACAAAAWA4CeKhLE00KiO5ZmuqmA6LywGs2OPgKEwk93NkGjohL1fRPjBLRhL4cAE
			ZfYOjAdzasgyCwVsEElkHHe95xhdXtt6xbMNh2DU5r6GVug0f6luMDgGKExONFYGYol1dzAldRJb
			BnWBK1N1cjBTi2RFjitwDpYqAQULDns7pqiqIiEAOw==
		}] \
		scale-va [image create photo -data { \
			R0lGODdhDwAgAKUwAFtzxJem2rKyssHCwsLCwcTDxMPExMTEw8TExMbGx8fHxsnJycvLy8zLy8zL
			zMvMy8vMzMzMy87Oz9DQ0NHQ0NHQ0dDR0NHR0dzc3Nzc3dzd3ODg4OHg4ODh4OHh4OTk5OXk5OTl
			5Obm5ujn6Ojo5+jo6Ovr7Ozr6+zr7Ovs6+vs7Ozs6+/u7+/v7u/v7/P08///////////////////
			/////////////////////////////////////////////ywAAAAADwAgAAAG/kBYAEAsGgEBIcCA
			YEAklwwHNDIhAQTmwgHVcD6l0otIKCgYja4GbGKREWeGxIL5iMKudzNdyWjuKnlYBQgLcnQdYCyC
			BHALaRcYiSUpLWRmDA9QkiEjKW5YTGcSExgbISQsoGVnmhKmIXiXTRERpR9gKpYAA4QMAsDAIiIn
			gr2FcpF2Iye7BQWGchV1VCervsHAVCa7BAeFaRQYXyKLbwqPcxkbHyQmjHC/2SIkJfCFEZu4qd2+
			aRJSQJRQRYYJmi5TwvRrIucWGBSMfMkR94VEsUsJFjwR58GOvYJNNInDVWLFKi0iMawpGbEVqTpg
			VkREJqHPlxLWLkWruSamE6UhZiI0iHBBA7sSKpAoOXIkSRAAOw==
		}] \
		scale-vd [image create photo -data { \
			R0lGODdhDwAgAKUmAHCFzKSx37y8vMnKysrKyczLzMvMzMzMy8zMzM3Nzs7OzdDQ0NLS0tTU1dbW
			1tfW1tfW19bX1tfX1+Dg4ODg4eDh4OTk5OXk5OTl5OXl5Ofn5+jn5+fo5+np6evq6+vr6uvr6+7u
			7vHw8fHx8PHx8fX19f//////////////////////////////////////////////////////////
			/////////////////////////////////////////////ywAAAAADwAgAAAG+UBTAEAsGgEBIcCA
			YDAaEspl4wkhAQTm4impXDQgUIlIKCic0EoFHBKREednZKLphEnv5hNCqdhDeFgFCFsNcxhgIoEE
			cIUSE4ggISNkZmiPGBxVblhMZw0OExYcHyKcZXENDaIcd5V6DKEabJQAA4MMArq6HR2ARLeEXHQd
			VbUFBVt7dFRtr7m7As21BAfCDQ8TXx2KbwqFERQWGh+/WHDQux0fIIsI14+zpdS4Tw1SGyCmZEyX
			Xvkg6OkBRYfNonrYtJEzVyZBoWwZ6rTjNzDbLEmntDzJtkbSwVSyDL4qxOcLxkrKGkBYQ+uKJSdd
			xklCouTIkSRBAAA7
		}] \
		scale-vn [image create photo -data { \
			R0lGODdhDwAgAKUwAFtzxJem2rKyssHCwsLCwcTDxMPExMTEw8TExMbGx8fHxsnJycvLy8zLy8zL
			zMvMy8vMzMzMy87Oz9DQ0NHQ0NHQ0dDR0NHR0dzc3Nzc3dzd3ODg4OHg4ODh4OHh4OTk5OXk5OTl
			5Obm5ujn6Ojo5+jo6Ovr7Ozr6+zr7Ovs6+vs7Ozs6+/u7+/v7u/v7/P08///////////////////
			/////////////////////////////////////////////ywAAAAADwAgAAAG/kBYAEAsGgEBIcCA
			YEAklwwHNDIhAQTmwgHVcD6l0otIKCgYja4GbGKREWeGxIL5iMKudzNdyWjuKnlYBQgLcnQdYCyC
			BHALaRcYiSUpLWRmDA9QkiEjKW5YTGcSExgbISQsoGVnmhKmIXiXTRERpR9gKpYAA4QMAsDAIiIn
			gr2FcpF2Iye7BQWGchV1VCervsHAVCa7BAeFaRQYXyKLbwqPcxkbHyQmjHC/2SIkJfCFEZu4qd2+
			aRJSQJRQRYYJmi5TwvRrIucWGBSMfMkR94VEsUsJFjwR58GOvYJNNInDVWLFKi0iMawpGbEVqTpg
			VkREJqHPlxLWLkWruSamE6UhZiI0iHBBA7sSKpAoOXIkSRAAOw==
		}] \
		sep-h [image create photo -data { \
			R0lGODlhFAACAKEAAMjIyP///8jIyMjIyCH5BAEKAAIALAAAAAAUAAIAAAIHhI+Zwe3/CgA7
		}] \
		sep-v [image create photo -data { \
			R0lGODlhAgAUAKEAAMjIyP///8jIyMjIyCH5BAEKAAIALAAAAAACABQAAAIHRIynyeudCgA7
		}] \
		sizegrip [image create photo -data { \
			R0lGODdhEAAQAJEAAO/r58a2rf///wAAACwAAAAAEAAQAAACJoSPqXvCKsJDcTZpQdVz7+VhIPZB
			JGkaYbJqonrCbOyqco1X7VoAADs=
		}] \
		spinarrowdown-a [image create photo -data { \
			R0lGODlhDAAMAMIFAAAAAE5jqFtzxJem2u/r5////////////yH5BAEKAAcALAAAAAAMAAwAAAMl
			GLXMJKq1F+WiIGtNy9ZF520XxIBl5U2mlbopIc+zMAh4rg9EAgA7
		}] \
		spinarrowdown-pa [image create photo -data { \
			R0lGODlhDAAMAMIFAAAAAE5jqIGOu83Jxtvb2////////////yH5BAEKAAcALAAAAAAMAAwAAAMk
			GLTME6q1F+WiBOgNCM7cBTGbM5LTaXmq9a3UIM9zIEB4bg8JADs=
		}] \
		spinarrowdown-p [image create photo -data { \
			R0lGODlhDAAMAMIFAAAAAE5jqIGOu83Jxtvb2////////////yH5BAEKAAcALAAAAAAMAAwAAAMk
			GLTME6q1F+WiIGtNydZE520XxIBl5U2mlbrpIM9zIEB4bg8JADs=
		}] \
		spinarrowup-a [image create photo -data { \
			R0lGODlhDAAMAMIFAAAAAE5jqFtzxJem2u/r5////////////yH5BAEKAAcALAAAAAAMAAwAAAMm
			KLo8FCRKKUYoOGcirtachwFglwHoZhZoi4Vs64ZyDX+qiN94wSUAOw==
		}] \
		spinarrowup-pa [image create photo -data { \
			R0lGODlhDAAMAMIFAAAAAE5jqIGOu83Jxtvb2////////////yH5BAEKAAcALAAAAAAMAAwAAAMk
			GLosEyNKGUQgOOd3tebep2iA2BFAuo1oqhKgK8NsSJ8haNMJADs=
		}] \
		spinarrowup-p [image create photo -data { \
			R0lGODlhDAAMAMIFAAAAAE5jqIGOu83Jxtvb2////////////yH5BAEKAAcALAAAAAAMAAwAAAMl
			GLosEyNKGUQgOOd3teYa8CkZYG4kYa4YuL4E986gh3Z2nOZPAgA7
		}] \
		tab-a [image create photo -data { \
			R0lGODlhIAAYAOeBAKCgoN7d3t/f3t/f3+Df39/g3+Dg4ODg4eHg4OHg4eDh4ODh4eHh4OHh4eLh
			4uLi4eLi4uLi4+Pi4uLj4uPj4+Pj5OTj4+Tj5OPk4+Pk5OTk4+Tk5OXl5ebl5eXm5eXm5ubm5ebm
			5ubm5+fm5ufm5+bn5ubn5+fn5ufn5+jn6Ojo6Ojo6eno6Ojp6Ojp6enp6urp6erp6unq6enq6urq
			6erq6uvr6+vr7Ozr6+zr7Ovs6+vs7Ozs6+zs7Ozs7e3s7O3s7ezt7Ozt7e3t7O3t7e7u7u7u7+/u
			7u/u7+7v7u7v7+/v8PDv7/Dv8O/w7+/w8PDw7/Dw8PHx8fHx8vLx8fHy8fHy8vLy8fLy8/Py8vPy
			8/Lz8/Pz8vPz8/T09PT09fX09PT19PT19fX19PX19fb19fb19vX29fX29vb29fb29vf39/f3+Pj3
			9/j3+Pf49/f4+Pj49/j4+Pj4+fn4+fj5+Pj5+fn5+Pn5+fr6+vr6+/v6+vv6+/r7+vr7+/z7/Pz8
			/P7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/iH5BAEKAP8ALAAAAAAgABgA
			AAj+AP8JHEiwoMGDCBMqTAgoAICHECNKnEgxwB+HAfb42bNHj54+eTruyaOHYx8+fPL04agnj0uM
			AALgmUmzph2ad27OnENnZp06dOzccQggDpw4b+SsWdNGKRs4bNi4WQNnKRumbNqsubr0zUM1YMGa
			CWumjJo0aMCaBZtGzdiwac88/BIGzJgvXsiAARMmzBgvX8SEweulsGG8e/s+7MK4sWMtWRhr4UJZ
			i+MuXLpg6bIFy0MpU6hQuUJlSpUqVkRLUV0atJTXsKtQef0wiu3buKNAsf0EyhMmv20vcQKlyRPe
			D5MYUYLESJHnzp0nUVIkyfPrRY5gv/4QCBEiQr7+9wDyg8iQ70SC9BgCZIiQ8UF+/PDhA0gPHw9t
			7MiBQ4eN/zbwYMMN/xGIQw43EPiffwMC+FANNdAwQw0yyFDDhDW8MCEMMrwAAwwxRBhDDDTAMAOJ
			LzzEggsquLCCCi28qAILMKpg440z4mhjCjY+hAIKJgB5QggmnBAkCieQcEIJJoxQApAimBDCCCSU
			MAIKJTzUAQgccNCBlx180CUHHnw55plojvnQBhlgsIEFF2ygQQUYYEBBBRtgYIGdGlyAwZwZVGCB
			oBZo8BAEEEyQaASIIsroBBJAEGmjiD6AqAONOvBQAwsw0EACDSDAwAENHJDAAg0YkIACnSKwAKsj
			ox4gqwIGPDTArQQQMICutxZw66/AAivAr8MCsNCxyCabbEAAOw==
		}] \
		tab-n [image create photo -data { \
			R0lGODlhIAAYAMZvAIyMjMLBwsPDwsPDw8PDxMTDw8TDxMPEw8PExMTEw8TExMXExcXFxMXFxcXF
			xsbFxcXGxcbGxsbGx8fGxsfGx8bHxsbHx8fHxsfHx8jIyMnIyMjJyMjJycnJyMnJycnJysrJycrJ
			ysnKycnKysrKycrKysrKy8vKysrLysrLy8vLzMzLy8zLzMvMy8vMzMzMy8zMzM3Nzc3Nzs7Nzc7N
			zs3Ozc3Ozs7Ozc7Ozs7Oz8/Ozs/Oz87Pzs7Pz8/Pzs/Pz9DQ0NDQ0dHQ0NHQ0dDR0NDR0dHR0dLS
			0tLS09PS0tLT0tLT09PT0tPT1NTT09TT1NPU1NTU09TU1NXV1dXV1tbV1dXW1dXW1tbW1dbW1tfW
			1tfW19bX1tbX19fX1tfX19jY2NjY2dnY2djZ2NjZ2dnZ2NnZ2dra2tra29va2tva29rb2trb29zb
			3Nzc3P7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/iH5
			BAEKAH8ALAAAAAAgABgAAAf+gH+Cg4SFhoeIiYqJbgEAj5CRkpOUAW2OAWlsaWloaGtnnWlnaJxr
			ampna5xoZ66YAAFms7S1ZLRlt7NhYrNjY2JkZY4AYMbHyMnKy8aPX8/PW9BbWl9eXc/Vz15f0tDY
			XI9UVlVYVFNZVVVWVlhTVFdW51P09efq7I9S+/z9T077nkQZ+KSflChSmkiB0uTRESRJkjBJgkSJ
			kiURj2Sk+PCIx49Kknh8ZKSkyZMoU6os+YhIkCJDggCZKVMmkSJAiMzcCUQIz52Pdvz40WMojh06
			fvgY+oMHDh87fPQ4ykOHjhw5duDI8SiGDRozasQYG+NGDBlj0c6gIQPtWLHTZ8k+ggHjhQsYLVrA
			uAtDxd0VLVSsWMGiLgsWL1a4QKzi0YkUJVKYKIFicokTlEto3nyZs+dHmkeUGEHCA2nRJUiEICFi
			BAgRoz+M8AAihAgQJUQ80tAhQwYNvzVw8J1hA3DiyJMTf4TBQgUMEyhguCChQoUIEjBUmHD9AoUK
			1C1ImDB+woVHDRpAUO8gffr2EB40kO8+PYP0C9wveKQAQQIFBihQQAIEKECAAQgoMIABB/hXAAIN
			EkjAhAcM8MgAGGao4YYcZiiAhxYuIuKIJJIYCAA7
		}] \
		tab-s [image create photo -data { \
			R0lGODlhIAAYAOeBAKCgoN7d3t/f3t/f3+Df39/g3+Dg4ODg4eHg4OHg4eDh4ODh4eHh4OHh4eLh
			4uLi4eLi4uLi4+Pi4uLj4uPj4+Pj5OTj4+Tj5OPk4+Pk5OTk4+Tk5OXl5ebl5eXm5eXm5ubm5ebm
			5ubm5+fm5ufm5+bn5ubn5+fn5ufn5+jn6Ojo6Ojo6eno6Ojp6Ojp6enp6urp6erp6unq6enq6urq
			6erq6uvr6+vr7Ozr6+zr7Ovs6+vs7Ozs6+zs7Ozs7e3s7O3s7ezt7Ozt7e3t7O3t7e7u7u7u7+/u
			7u/u7+7v7u7v7+/v8PDv7/Dv8O/w7+/w8PDw7/Dw8PHx8fHx8vLx8fHy8fHy8vLy8fLy8/Py8vPy
			8/Lz8/Pz8vPz8/T09PT09fX09PT19PT19fX19PX19fb19fb19vX29fX29vb29fb29vf39/f3+Pj3
			9/j3+Pf49/f4+Pj49/j4+Pj4+fn4+fj5+Pj5+fn5+Pn5+fr6+vr6+/v6+vv6+/r7+vr7+/z7/Pz8
			/P7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+
			/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/iH5BAEKAP8ALAAAAAAgABgA
			AAj+AP8JHEiwoMGDCBMqTAgoAICHECNKnEgxwB+HAfb42bNHj54+eTruyaOHYx8+fPL04agnj0uM
			AALgmUmzph2ad27OnENnZp06dOzccQggDpw4b+SsWdNGKRs4bNi4WQNnKRumbNqsubr0zUM1YMGa
			CWumjJo0aMCaBZtGzdiwac88/BIGzJgvXsiAARMmzBgvX8SEweulsGG8e/s+7MK4sWMtWRhr4UJZ
			i+MuXLpg6bIFy0MpU6hQuUJlSpUqVkRLUV0atJTXsKtQef0wiu3buKNAsf0EyhMmv20vcQKlyRPe
			D5MYUYLESJHnzp0nUVIkyfPrRY5gv/4QCBEiQr7+9wDyg8iQ70SC9BgCZIiQ8UF+/PDhA0gPHw9t
			7MiBQ4eN/zbwYMMN/xGIQw43EPiffwMC+FANNdAwQw0yyFDDhDW8MCEMMrwAAwwxRBhDDDTAMAOJ
			LzzEggsquLCCCi28qAILMKpg440z4mhjCjY+hAIKJgB5QggmnBAkCieQcEIJJoxQApAimBDCCCSU
			MAIKJTzUAQgccNCBlx180CUHHnw55plojvnQBhlgsIEFF2ygQQUYYEBBBRtgYIGdGlyAwZwZVGCB
			oBZo8BAEEEyQaASIIsroBBJAEGmjiD6AqAONOvBQAwsw0EACDSDAwAENHJDAAg0YkIACnSKwAKsj
			ox4gqwIGPDTArQQQMICutxZw66/AAivAr8MCsNCxyCabbEAAOw==
		}] \
		toolbutton-a [image create photo -data { \
			R0lGODlhHAAcAKU1AFtzxF92xWB3xWh9x2h+x3aKzniLzpWl2Jal2Zem2qSu0aSv0dDS09PT1NLT
			19TU1NbW1tfX19DX7NHY7NjY2NLY7dnZ2dvb29zc2d3d3d7e3uDg4Nvg8tvh8OHh4eLi4uTk5OXl
			5efn5+jo6Onp6evr6+zs7O7u7vDw8PHx8fLy8vPz8/L0+fT09PX19/n49/r6+vv6+/v7+v79/v7+
			/v///////////////////////////////////////////yH5BAEKAD8ALAAAAAAcABwAAAb+wBon
			IQAYj8hkUpDgCA2TDmtGq1qvWNqM1ZkUhpVYTAYrw8Rks3oNkxBdrbh8Tq/LXcWXas/v+/98L0Yr
			KYWGh4iJhitGKI6PkJGSkUYnlpeYmZqZRiaen6ChoqFGJaanqKmqqUYkrq+wsbKxRiO2t7i5urkA
			ASK/wMHCw8JGIcfIycrLykYgz9DR0tPSRh/X2Nna29pGHt/g4eLj4kYb5+jp6uvqRhrv8PHy8/JG
			Gff4+fr7+kYX/wADChwo0IiFgwgTKlyo0AiFhxAjSpwo0QiGCBgzatzIMSOGXg4giBxJsqTJkQ4C
			IFjwoKXLlzBjulSAgAMBmS8bMMD5QOcOACccDgRQQpRogANOggAAOw==
		}] \
		toolbutton-d [image create photo -data { \
			R0lGODlhHAAcAKUxAKCgoKGhoaKioqOjo6SkpKWlpaampqmpqaqqqqysrK6urrCwsLKysrS0tLa2
			trm5ubq6ur29vb6+vr+/v8HBwcLCwsPDw8XFxcfHx9ra2tvb29zc3N/f3+Dg4OHh4ePj4+Tk5OXl
			5ebm5ufn5+np6evr6+zs7O3t7e7u7u/v7/Hx8fPz8/T09PX19fj4+P39/f7+/v//////////////
			/////////////////////////////////////////////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5
			BAEKAD8ALAAAAAAcABwAAAb+wB+FIikajZMKZXI8Jn8/C6aUcr1g2Kx2C3u5UqXLL5Jalc/mNHqt
			XkUerrh8Tq/THw67fh93NFosgIKBhIOGhSwNDCuMjY6PkI8MCyqVlpeYmZgLCimen6ChoqEKCSin
			qKmqq6oJCCewsbKztLMIBya5uru8vbwHBiXCw8TFxsUGCCTLzM3Oz84KDdDU1csQDyPa29zd3t14
			IuLj5OXm5X4h6uvs7e7tiiDy8/T19vWTH/r7/P3+/Zw8CBxIsKDBgqU4KFzIsKHDhq4eSpyo8JaH
			DhczYtyosSPHDsA0iBxJsqTJkgYOYMigYcOGkyNdamDZ8mUGDAd+FMhAEyYaSZ4/MxSA8oNAAABI
			kyINMEDAUaVJAxCAEgQAOw==
		}] \
		toolbutton-n [image create photo -data { \
			R0lGODlhHAAcAKU3AI2NjY6Ojo+Pj5CQkJGRkZOTk5SUlJeXl5mZmZubm52dnZ6enqCgoKKioqWl
			paenp6urq6ysrLCwsLGxsbKysrS0tLW1tba2tre3t7m5ubu7u9LS0tPT09TU1NXV1djY2NnZ2dra
			2tvb293d3d7e3uDg4OHh4eLi4uTk5OXl5efn5+jo6Onp6evr6+zs7O7u7vDw8PLy8vPz8/b29vf3
			9/39/f7+/v///////////////////////////////////yH5BAEKAD8ALAAAAAAcABwAAAb+wF+l
			MikajRRLhXI8Ui6/H0ajctFqtqx2y7XVaC5V5idxwczoszrNXsMkENpMTp/b6/j7DPLI+/V/Dw4y
			MYSGhYiHiokxDg0wkJGSk5STDQwvmZqbnJ2cDAsuoqOkpaalCwktq6ytrq+uCQgstLW2t7i3CAcr
			vb6/wMHABwYqxsfIycrJBggpz9DR0tPSCg4o2Nna29zbERAn4eLj5OXkfCbp6uvs7eyCJfHy8/T1
			9I4k+fr7/P38lyMCChxIsCBBUCISKlzIsCHDVCAiSpxIsSJFWR8yatzIsSPHXSJChBwpsiTJkyZD
			EOvAsqXLlzBfGjiggUMHDx5itsTZweYmzZwcNBz4UWCDT50uOWxIuqFAlB8EAgCYSnVqgAECpFal
			GoBAlCAAOw==
		}] \
		toolbutton-pa [image create photo -data { \
			R0lGODlhHAAcAMZIAFtzxF92xWB3xWh9x2h+x3aKzniLzpejzZWl2Jal2Zem2qSuzqSu0aSv0au0
			0LS70cHF0sjK09DS09LT1NPT1NLT19TU1NTV1tXV1NXV1dbW1tfX19DX7NjY19HY7NjY2NLY7dnZ
			2dva2Nvb29zc2d3d3d7e3uDg4Nvg8tvh8OHh4eLi4t7i8OTk5OXl5efn5+To8+jo6Onp6evr6+zs
			7O7u7vDw8PHx8fLy8vPz8/T08/L0+fT09PP0+PX19fX19vX19/f39vn49/r6+vv6+/v7+v79/v7+
			/v//////////////////////////////////////////////////////////////////////////
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////////yH+
			EUNyZWF0ZWQgd2l0aCBHSU1QACwAAAAAHAAcAAAH/oBIKAoCAIaHiImJAgooggYeKTtGR5WWl5hH
			RjspHgWDICwwPURERUOoqaqoRaU9MCwchEC0Pz48uLm6uzw+P7RAhUJCQTo4x8jJysg6QcOGOTk4
			N9TV1tfXONGGNt3e3+Dh4IY15ebn6OnohjTt7u/w8fCGM/X29/j5+IYy/f7/AAMCNBSjoMGDCBMi
			BBDghcOHECNKjGjIhcWLGDNqzGiohcePIEOKDGlohcmTKFOqTGlIhcuXMGPKjGnohM2bOHPqzGnI
			hM+fQIMKDWqohNGjSJMqTWpohNOnUKNKjWoohNWrWLNqzWrog9evYMOKDWuIBAkRHTaoXcu27doO
			TCLMMqxA90IGDXjz6t2rIcMFuhUCJGjg4EGECRYyYLDAuLFjDBksTIjwwAGDBCgIHFgAQQIFx6BB
			U5AAYcGBAY5QIAigqHXrAAgcBQIAOw==
		}] \
		toolbutton-p [image create photo -data { \
			R0lGODlhHAAcAKUxAE9kqlNnq1ptrWd4s2h5s4GPvIKPvYOQvY6Xto6YtrW2t7e3uLa3u7i4uLq6
			uru7u7W7zba8zby8vLa8zr29vb6+vr+/vcDAwMHBwb7D0cPDw77D0sTExMbGxsfHx8nJycrKyszM
			zM3Nzc/Pz9HR0dLS0tPT09LU2NTU1NXV19jX19nZ2drZ2tra2d3c3d3d3d7e3v//////////////
			/////////////////////////////////////////////ywAAAAAHAAcAAAG/kDY5hAAGI/IZDJw
			2AgJkczJ9apar9iX65SJDIYTFqu1Kq/EZLN6vYIQU6i4fE6vy1NFVWnP7/v/fCpGJiSFhoeIiYYm
			RoqOj4VGI5OUlZaXlkYim5ydnp+eRiGjpKWmp6ZGIKusra6vrqqws7QgAAEfubq7vL28Rh7BwsPE
			xcRGHcnKy8zNzEYc0dLT1NXURhrZ2tvc3dzY3uHiGkYY5ufo6erpRhfu7/Dx8vFGFfb3+Pn6+UYU
			/v8AAwoMaESCwYMIEypMaMTCg4cQI0qcCNHCLQYOMmrcyLGjRgYBDCRoQLKkyZMoSyIwsEFASpML
			FLxsEFOAkw0FiijZqSRABAEnQQAAOw==
		}] \
		tree-d [image create photo -data { \
			R0lGODdhGAAYAIQgALm5udbX29jZ2tnZ2dra2tvb29zc29zc3N3d3d7d3N7e3uDg4OHh4ePj4+Tk
			5OXl5efn5+np6erq6uvr6+3t7e7u7vDw8PHx8fLy8vPz8/X19PX19fb29vb29/b2+Pj49ywAAAAA
			GAAYAAAFuSAgjmRpkl7HbWzrvhvXeeKnZXiu77n2iRmMcEgsFjOii3LJbDovIot0Sq1aLaKKdsvt
			eisiinhMLpspool6zW67JyKJfE6v2yWiiH7P7/sjIhCCg4SFhhCBh4qGIg+Oj5CRkg8iDpaXmJma
			DiINnp+goaINIgymp6ipqgwiC66vsLGyCyIKtre4uboKIgi+v8DBwggiB8bHyMnKByIJBgXQ0dLT
			0QYJIgECAwTc3d7fBAMCASfl5gAhADs=
		}] \
		tree-h [image create photo -data { \
			R0lGODdhGAAYAKUhALKystLT19TV1tXV1dbW1tfX19jY19jY2NnZ2dva2Nvb293d3d7e3uDg4OHh
			4eLi4uTk5OXl5efn5+jo6Onp6evr6+zs7O7u7vDw8PHx8fLy8vT08/T09PX19fX19vX19/f39v//
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////ywAAAAAGAAYAAAGx0CAcEgsGokfT4fD
			bDqfnI7nIwRtNNisdpvdgISajHhMLpc1Qox6zW67McKLfE6v2y9Ci37P7/stQhWCg4SFhhVCFIqL
			jI2OFEITkpOUlZYTQhKam5ydnhJCEaKjpKWmEUIQqqusra4QQg+ys7S1tg9CDrq7vL2+DkINwsPE
			xcYNQgzKy8zNzgxCC9LT1NXWC0IK2tvc3d4KQgji4+Tl5ghCB+rr7O3uB0IJBgX09fb39QYJQgEC
			AwQAAwocSGCAgABHEioEEAQAOw==
		}] \
		tree-n [image create photo -data { \
			R0lGODdhGAAYAKUhALKystLT19TV1tXV1dbW1tfX19jY19jY2NnZ2dva2Nvb293d3d7e3uDg4OHh
			4eLi4uTk5OXl5efn5+jo6Onp6evr6+zs7O7u7vDw8PHx8fLy8vT08/T09PX19fX19vX19/f39v//
			////////////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////ywAAAAAGAAYAAAGx0CAcEgsGokfT4fD
			bDqfnI7nIwRtNNisdpvdgISajHhMLpc1Qox6zW67McKLfE6v2y9Ci37P7/stQhWCg4SFhhVCFIqL
			jI2OFEITkpOUlZYTQhKam5ydnhJCEaKjpKWmEUIQqqusra4QQg+ys7S1tg9CDrq7vL2+DkINwsPE
			xcYNQgzKy8zNzgxCC9LT1NXWC0IK2tvc3d4KQgji4+Tl5ghCB+rr7O3uB0IJBgX09fb39QYJQgEC
			AwQAAwocSGCAgABHEioEEAQAOw==
		}] \
		tree-p [image create photo -data { \
			R0lGODdhGAAYAIQgAKGhob6/w8DBwsHBwcLCwsPDw8TEw8TExMXFxcfGxMfHx8jIyMnJycvLy8zM
			zM3Nzc/Pz9DQ0NHR0dLS0tPT09XV1dbW1tjY2Nra2tvb293d3N3d3d7e3t7e397e4ODg3ywAAAAA
			GAAYAAAFuSAgjmRpkl7HbWzrvhvXeeKnZXiu77n2ibygMCPCGI/IpBIjujif0Kj0IrJYr9is1iKq
			eL/gsLgiopjP6LSaIpq43/C4fCKS2O/4vF4iivj/gIGCESIQhoeIiYoQIg+Oj5CRkg8iDpaXmJma
			DiINnp+goaINIgymp6ipqgwiC66vsLGyCyIKtre4uboKIgi+v8DBwggiB8bHyMnKByIJBgXQ0dLT
			0QYJIgECAwTc3d7fBAMCASfl5gAhADs=
		}] \
	 ]
    
    variable colors
    array set colors {
        -frame          "#d8d8d8"
        -lighter        "#fcfcfc"
        -dark           "#c8c8c8"
        -darker         "#9e9e9e"
        -darkest        "#cacaca"
        -selectbg       "#3d3d3d"
        -selectfg       "#fcfcfc"
        -disabledfg     "#b3b3b3"
        -entryfocus     "#6f6f6f"
        -tabbg          "#c9c9c9"
        -tabborder      "#b7b7b7"
        -troughcolor    "#d7d7d7"
        -troughborder   "#a7a7a7"
        -checklight     "#f5f5f5"
	-eborder        "#4562c4"
    }

    ttk::style theme create scidblue -parent clam -settings {
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

        ## Treeview.
        ttk::style element create Treeheading.cell image \
            [list $I(tree-n) \
                 selected $I(tree-p) \
                 disabled $I(tree-d) \
                 pressed $I(tree-p) \
                 active $I(tree-h) \
                ] \
            -border 4 -sticky ew

        ttk::style configure Row -background "#efefef"
        ttk::style map Row -background [list \
                                       {focus selected} "#6474d4" \
                                       selected "#7484e4" \
                                       alternate white]
        ttk::style map Item -foreground [list selected white]
        ttk::style map Cell -foreground [list selected white]
	# Treeview (since 8.6b1 or 8.5.9)
	ttk::style configure Treeview -background white
	ttk::style map Treeview \
	  -background [list selected "#5464c4"] \
	  -foreground [list selected $colors(-selectfg)]

        ## Buttons.
        ttk::style configure TButton -padding {2 0} -anchor center
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
            -border {4 9 4 18} -padding {2 2} -sticky news

        ## Checkbuttons.
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
        ttk::style element create Menubutton.border image \
             [list $I(button-n) \
                  selected $I(button-p) \
                  disabled $I(button-d) \
                  active $I(button-a) \
                 ] \
            -border 4 -sticky ew


        ## Toolbar buttons.
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
        ttk::style configure TEntry -padding 1 -insertwidth 1 \
            -fieldbackground white

        ttk::style map TEntry \
            -fieldbackground [list readonly $colors(-frame)] \
            -bordercolor     [list focus $colors(-eborder)] \
            -lightcolor      [list focus $colors(-entryfocus)] \
            -darkcolor       [list focus $colors(-entryfocus)] \
            ;


        ## Combobox.
        ttk::style configure TCombobox -selectbackground
        # The following line is added by GC.
        ttk::style configure TCombobox -padding 0

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

        ## Spinbox.
        ttk::style configure TSpinbox -selectbackground #ffffff -selectforeground #202020

        ttk::style element create Spinbox.downarrow image \
            [list $I(spinarrowdown-a) \
                 disabled $I(spinarrowdown-a) \
                 pressed $I(spinarrowdown-pa) \
                 active $I(spinarrowdown-p) \
                ] \
            -border 1 -sticky {}
        ttk::style element create Spinbox.uparrow image \
            [list $I(spinarrowup-a) \
                 disabled $I(spinarrowup-a) \
                 pressed $I(spinarrowup-pa) \
                 active $I(spinarrowup-p) \
                ] \
            -border 1 -sticky {}

        ## Notebooks.
        # The following line is added by GC.
        ttk::style configure TNotebook.Tab -padding {3 3}
        ::ttk::style element create tab \
            image [list $I(tab-n) selected $I(tab-s) active $I(tab-a)] -border {3 6 3 12} -padding {3 3}

        ## Labelframes.
        ttk::style configure TLabelframe -borderwidth 2 -relief groove

        ## Scrollbars.
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
        ttk::style element create Horizontal.Progressbar.pbar image $I(progress-h) \
            -border {2 2 1 1}
        ttk::style element create Vertical.Progressbar.pbar image $I(progress-v) \
            -border {2 2 1 1}

        ttk::style configure TProgressbar -bordercolor $colors(-troughborder)

        ## Statusbar parts.
        ttk::style element create sizegrip image $I(sizegrip)

        ttk::style configure Sash -sashthickness 6 -gripcount 16
    }
}

