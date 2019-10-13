---
{
  'type': 'blog',
  'author': 'Brian Ginsburg',
  'title': 'nginlog',
  'description': 'nginlog is an nginx traffic analysis tool',
  'image': '/images/article-covers/map.png',
  'draft': false,
  'published': '2017-09-09',
}
---

nginlog is an nginx traffic analysis tool. I submitted nginlog as my final project for the 2017
Full Stack Web Development course at Portland State University.

nginlog consists of two components. A server component logs HTTP requests, and a
client application displays the data in charts and a map.

## Server

The server component could be on any machine where nginx has been configured to log
requests as JSON. A Python script reads the JSON log entries and inserts them
into a CouchDB database. A set of views is defined on the data and served by
CouchDB through nginx as a proxy. Requests the client makes to CouchDB are not
logged.

## Client

The client application uses the AngularJS framework, node as a server, Chart.js
for charts, md-data-table for tables, and Google Charts for a map of requests by
country.

The charts and tables display total and unique requests by country and host, as
well as total requests by status code and user agent.

![nginlog Donut Charts](/images/blog/donuts.png)

The client application is responsive to screen size. On a mobile device, the
sidebar menu hides under a menu button and all visualizations resize or
transform to fit neatly into a single column.

![nginlog Responsive View](/images/blog/responsive.png)

## Utility

To use nginlog in a production setting, many improvements would be needed. The
server component should require authentication for all requests of data. Users
should be able to select time periods for each visualization, and search
functionality should be added to all data tables.

Beyond that, more robust tools do the work of nginlog and more. To compete
against these tools, serious commitment and a significant amount of time and
capital would be needed.
