---
title: "3D terrain generation with THREE.js"
date: 2012-01-30T00:00:00+09:00
highlight: false
draft: false
---

I’m increasingly interested in the use and application of Perlin and Simplex style noise generation to real world problems, and even moreso for the simulation of real world environments. This has come from my personal side projects in game development. If you’re not familiar with noise generation like Perlin and Simplex noise, a quick Google Search will show you all you need.

All you really need to know about Perlin noise for article is that it can be used and manipulated to generate random terrain thats reasonably smooth and realistic.

### THREE.js

THREE.js is an awesome abstraction on various rendering techniques for browsers. It supports WebGL, Canvas and SVG. I’ve given a couple of talks on 3D Javascript on top of THREE.js at a number of conferences. Check them out for more information, and some interesting applications of THREE.js in various situations.

### Objective

The objective of this example is not to produce a real playable game. The objective was to implement a number of terrain modification techniques that I could reuse later for a game style project, and to get a reasonable render rate for terrain samples.

![](/uploads/3d-terrain-01.png)

<!-- ### Live Demo

The image above is great, but its more fun to checkout the real demo.

View the demo here.

Some good settings for terrain that looks somewhat realistic are:

* Terrain Factor X: 5
* Terrain Factor Y: 3 -->

### Plane Geometry

The PlaneGeometry object in THREE.js handles some niceties for us in smoothing between points, and making it really easy to setup pliable terrain meshes.

There are some tricks, however, to be able to easily modify the terrain vertices on the fly and have them update when rendering.

When creating the PlaneGeometry, you do it as normal, but specify the terrain is dynamic:

```javascript
var geometry = new THREE.PlaneGeometry(
  100, 100, // Width and Height
  10, 10    // Terrain resolution
);
geometry.dynamic = true;
```

Setting dynamic will allow the vertices to change, and the rendered result to display, later. The resolution in this example is 10, meaning there are 10 faces in the x direction, and 10 faces in the y direction. Since the width and height are both 100, this means that the faces are 10x10 each, to result in terrain that is a total 100x100 in size.

This is not everything, however. We need to modify some internals of the geometry each time they are changed to indicate to the renderer that the vertices have changed, and that the buffered rendering information needs to be changed.

For each time you change the vertices, perform the following:

```javascript
geometry.__dirtyVertices = true;
geometry.computeCentroids();
```

Without the above, the PlaneGeometry will appear flat even after changing vertices.

This took some digging and asking around on IRC to get, and I hope that helps people in the future when playing with geometry in THREE.js

### Dynamic vertex modification

For this example, I wanted a simple way to modify vertices in single functions so they were testable, and have the new geometry returned.

This means I can pass the existing vertex information to any terrain modification method. This method alters the position of vertices for the terrain, and returns the new vertices. I can then pass the result of that to a generic terrain building / modification method, to save unnecessarily rewriting any functionality.

To facilitate this, I built the function applyTerrainTransformation:

```javascript
HtmlTerrain.prototype.applyTerrainTransform = function(fn) {
  var geometry = fn(self.terrain.geometry);
  geometry.__dirtyVertices = true;
  geometry.computeCentroids();
  self.buildTerrain(geometry);
  self.terrain.geometry = geometry;
  return geometry;
};
```

This simply grabs the current geometry, passes it to the fn (function) passed in, calls buildTerrain on the result, and returns the new geometry.

The buildTerrain function builds the terrain from the specified geometry:

```javascript
HtmlTerrain.prototype.buildTerrain = function(geometry) {
  var mesh = new THREE.Mesh(geometry, new THREE.MeshLambertMaterial({color: 0xcccccc}));
  mesh.rotation.x = -90 * Math.PI / 180;
  self.scene.remove(self.scene.getChildByName("Terrain"));
  mesh.name = "Terrain";
  self.scene.add(mesh);
};
```

This is essentially a replacement of the mesh in the scene.

Now, I can build many functions that take geometry, and have them return the geometry. The rest is handled by the above functions. Here’s an example for the terrain raising:

```javascript
HtmlTerrain.prototype.raiseTerrain = function(geometry) {
  for (var i = 0; i < geometry.vertices.length; i++) {
    geometry.vertices[i].position.z += 3;
  }
  return geometry;
};
```

### Conclusion

I think when I started writing this blog post, I had a point to make. At the conclusion of it, I don’t know if I made one.

Mostly, I wanted to showcase some basic terrain generation in Javascript with THREE.js, and to demonstrate the terrain modification and vertex dirty method to assist anyone else thats trying something similar.
