---
title: "2D Terrain Generation with Processing"
date: 2012-01-06T00:00:00+09:00
highlight: false
draft: false
tags: ['processing', 'gamedev', 'java']
---

Yeah yeah.. You’ve heard it all before. Terrain generation. Perlin noise. All that jazz. Yes, well, I have gone and done it again, and I have used this attempt at 2D terrain generation to try and get a better understanding of the control I have over Perlin noise, and how to sculpt it to represent terrain that looks and feels real.

I’m using [Processing][processing] in this example, as its a nice and quick way to get some graphics output and lets me focus on the math side of things. Its also got the [Processing.js][processingjs] port which allows the same sketches to be run in web browsers, which is kick-ass. Processing is a language built on top of Java that allows you to fallback to using Java when and if you need to. Check it out.

This is the first attempt at rendering the terrain, its a Perlin generation of the top level in 1D, and then simple unmodified or scaled perlin generation in 2D for the caves. Its pretty boring.

![Terrain Sample 1](/uploads/2012/01/06/Screen%20Shot%202012-01-02%20at%2011.19.48%20PM.png)

My second attempt used a new multiplication of values technique to produce more realistic caves. You can see in the follow screenshot my first encounter with repeating perlin noise. At this stage, I was not sure what was causing the repeat. [John][jwm] suggested that it was a limited set of data, and the nature of the `noise()` function in Processing being designed to produce limited data for seamless wrapping. This turned out to be true, and I made changes later.

![Terrain Sample 2](/uploads/2012/01/06/Screen%20Shot%202012-01-02%20at%2011.33.24%20PM.png)

After looking at various other games, specifically [Terraria][terraria], I realised that the desired variety of caves and general terrain could not be done in a single pass. Thus, I started doing “SmallCaves” and “LargeCaves” generation, which started showing some more interesting results:

![Terrain Sample 3](/uploads/2012/01/06/Screen%20Shot%202012-01-03%20at%2012.25.56%20AM.png)

![Terrain Sample 4](/uploads/2012/01/06/Screen%20Shot%202012-01-03%20at%203.05.05%20PM.png")

The latest samples I have use a technique that [Jason][jase-twitter] recommended, which was to scale the X and Y for certain caves differently in order to achieve more “walkable” caves. This produced a good result. At this high level view (zoomed out) the terrain looks a little funny. Once the terrain is scaled and tiled correctly, it should look and feel a lot better whilst playing.

![Terrain Sample 5](/uploads/2012/01/06/Screen%20Shot%202012-01-06%20at%2011.35.09%20PM.png)

![Terrain Sample 6](/uploads/2012/01/06/Screen%20Shot%202012-01-06%20at%2011.13.12%20PM.png)

I’d love some feedback on this. Any comments, suggestions or anything. I’m not entirely sure the current terrain will be final, and it will probably need to be tweaked, and I would love to hear your ideas.

Coming up next, I will be adding new tile types with various colours and game modifiers. The first modified tile “Water” is currently in deveopment, it has a blue colour, and adjusts movement to 0.5 actual speed, to simulate the motion in water.

[processing]: https://processing.org "Processing web site"
[processingjs]: http://processingjs.org "Processing.JS web site"
[jwm]: http://plural.cc "John Marsden's personal website"
[terraria]: http://terraria.org "Terraia, the game!"
[jase-twitter]: https://twitter.com/jasedeacon "Jase Deacon's Twitter page"