# fl_animated_linechart

[![Codemagic build status](https://api.codemagic.io/apps/5d5e513ff8278e001ca52adf/5d5e513ff8278e001ca52ade/status_badge.svg)](https://codemagic.io/apps/5d5e513ff8278e001ca52adf/5d5e513ff8278e001ca52ade/latest_build)

![Animations](chart.gif)

An animated chart library for flutter.
 - Support for datetime axis
 - Multiple y axis, supporting different units
 - Highlight selection
 - Animation of the chart
 - Tested with more than 3000 points and still performing

There are currently two different charts:
 - line chart
 - area chart

## Getting Started

Try the sample project or include in your project.

Highlight for the line chart:
![Chart example with highlight](withSelection.png)

Area chart:
![Area Chart example](areaChart.png)

Example code:

    LineChart lineChart = LineChart.fromDateTimeMaps([line1, line2], [Colors.green, Colors.blue]);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: AnimatedLineChart(lineChart)),
            ]
        ),
      ),
    );

The example app, can toggle between line chart and area chart.
![Example app](exampleScreenshot.png)
