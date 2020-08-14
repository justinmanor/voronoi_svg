import megamu.mesh.*;
  
PShape s;
PShape dot, dot2;
float[][]  verts = new float[28828][2]; //make 1st index be count+1 as seen in console (or maybe just count, no +1)
float[][] myEdges;
MPolygon[] myRegions;
  
  
PrintWriter lines;
  
PrintWriter regions;
  
int maxP = 15;  
  
void setup() {
  size(5120, 2700);
  //initFXAA();
  //smooth(32);
  pixelDensity(2);
  s = loadShape("FOXP2_glow6.svg");
  
  int count = s.getChildCount();
  println("Count = " + count);
  dot = s.getChild(0);
  //int vcount = dot.getVertexCount();
  //println("vert count = " + vcount);
  
  lines = createWriter("lines.txt"); 
  lines.println("x,y");
  regions = createWriter("regions.txt"); 
  regions.println("n,x0,y0,x1,y1,x2,y2,x3,y3,x4,y4,x5,y5,x6,y6,x7,y7,x8,y8,x9,y9,x10,y10,x11,y11,x12,y12,x13,y13,x14,y14");
  
  for (int i = 1 ; i < s.getChildCount() ; i++) {
    if (i%1000 == 0) println(i);
    dot = s.getChild(i);
    //println("childs = " + dot.getChildCount());
    //println("verts = " + dot.getVertexCount());
    //println(getFamilyName(dot.getFamily()));
    //println(getKindName(dot.getKind()));
    //println(dot.getParams());
    //PVector v = dot.getVertex(0);
    verts[i-1][0] = dot.getParam(0);
    verts[i-1][1] = dot.getParam(1);
  }
  println("making voronoi");
  Voronoi myVoronoi = new Voronoi( verts );
  println("making polygons");
  myRegions = myVoronoi.getRegions();
  println("making edges");
  myEdges = myVoronoi.getEdges();
  
  strokeWeight(1.0);
  
  drawNetwork();
  //drawRegions();
}

void drawNetwork() {
  background(0);
  //shape(s, 0, 0, 2000, 700);
  stroke(255);
  float scale = 4.7;
    
    
  for(int i=0; i<myEdges.length; i++) {
    
    if (i%100 == 0) println(i);
    
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    
    float l = sqrt((endX-startX)*(endX-startX) + (endY-startY)*(endY-startY));
    if (l> 9) l = 9;
    
    strokeWeight(9);
    //strokeWeight(7.5 + abs(startX)/200.0); //thicker on right
    //if (l < 0) l = 0;
    //strokeWeight(1 + abs(l)); // length determines thickness
    
    //if (sqrt((endX - startX)*(endX - startX) + (endY - startY)*(endY - startY)) < 20.0)  
      line( scale*startX, scale*startY, scale*endX, scale*endY );
      lines.println(scale*startX + "," + scale*startY + "," + scale*endX + "," + scale*endY);
  }
  
  strokeWeight(2.0);
  
  /* 
  for(int i=0; i<myEdges.length; i++) {
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    
      stroke(200);
      fill(0);
      ellipse( scale*startX, scale*startY, 10,10);
      ellipse( scale*endX, scale*endY,10,10 );
      
      //lines.println(scale*startX + ", " + scale*startY + ", " + scale*endX + ", " + scale*endY); // Write the coordinate to the file
  }
  */
  lines.flush();
  lines.close();
}

void drawRegions() {
  scale(6.5);
  background(0);
  noFill();
  strokeWeight(0.1);
  stroke(255);
  float s = 0.8;
  
  for(int i=0; i<myRegions.length; i++)
  {
    
    if (i%100 == 0) println(i);
    // an array of points
    float[][] region = myRegions[i].getCoords();
    
    //myRegions[i].draw(this); // draw this shape

    
    regions.print(region.length + ",");
    
    float xc=0,yc=0;
    float shrinkage = 0.33;
    
    for (int j = 0 ; j < region.length ; j++) {
      xc += region[j][0];
      yc += region[j][1];
    }    
    
    xc /= region.length;
    yc /= region.length;
    
    for (int j = 0 ; j < region.length ; j++) {
      
      float newX = (1.0 - shrinkage)*region[j][0] + shrinkage*xc;
      float newY = (1.0 - shrinkage)*region[j][1] + shrinkage*yc;
      region[j][0] = newX;
      region[j][1] = newY;
      regions.print(newX + "," + newY + ",");
    }
    
    for (int k = region.length ; k < maxP ; k++) {
      regions.print("0,0,");
      
    }
    regions.println();
    
    pushMatrix();
    
    //noFill();
    //translate(200,-2500);
    //scale(s);
    //stroke(random(255), random(255), random(255));
    fill(255);
    beginShape();
    for (int j = 0 ; j < region.length ; j++) {
      vertex(region[j][0], region[j][1]);
    }    
    endShape(CLOSE);
    popMatrix();
  }
  regions.flush();
  regions.close();
  /*

  for(int i=0; i<myEdges.length; i++) {
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    
      //stroke(0);
      noStroke();
      fill(255);
      ellipse( s*startX, scale*startY, 7,7);
      //ellipse( s*endX, scale*endY,10,10 );
  }  
  */
}

String getFamilyName(int family) 
{
  switch (family) 
  {
  case GROUP:
    return "GROUP";
  case PShape.PRIMITIVE:
    return "PRIMITIVE";
  case PShape.GEOMETRY:
    return "GEOMETRY";
  case PShape.PATH:
    return "PATH";
  }
  return "unknown: " + family;
}
 
String getKindName(int kind) 
{
  switch (kind) 
  {
  case LINE:
    return "LINE";
  case PShape.ELLIPSE:
    return "ELLIPSE";
  case PShape.RECT:
    return "RECT";
  case 0:
    return "(PATH)";
  }
  return "unknown: " + kind;
}
/*
PShader fxaa;
 
public void initFXAA() {
    String[] vertSource = {
        "#version 130",
 
        "uniform mat4 transform;",
 
        "in vec4 vertex;",
        "in vec2 texCoord;",
 
        "out vec2 vertTexCoord;",
 
        "void main() {",
            "vertTexCoord = texCoord;",
            "gl_Position = transform * vertex;",
        "}"
    };
    String[] fragSource = {
        "#version 130",
 
        "const vec3 LUMA = vec3(0.299, 0.587, 0.114);",
        "const float SPAN_MAX = 8.0;",
        "const float REDUCE_MUL = 1.0 / 8.0;",
        "const float REDUCE_MIN = 1.0 / 128.0;",
 
        "uniform sampler2D texture;",
        "uniform vec2 texOffset;",
 
        "in vec2 vertTexCoord;",
 
        "out vec4 fragColor;",
 
        "void main() {",
 
            "float lumaNW = dot(texture2D(texture, vertTexCoord.xy + vec2(-1.0, -1.0) * texOffset).rgb, LUMA);",
            "float lumaNE = dot(texture2D(texture, vertTexCoord.xy + vec2(+1.0, -1.0) * texOffset).rgb, LUMA);",
            "float lumaSW = dot(texture2D(texture, vertTexCoord.xy + vec2(-1.0, +1.0) * texOffset).rgb, LUMA);",
            "float lumaSE = dot(texture2D(texture, vertTexCoord.xy + vec2(+1.0, +1.0) * texOffset).rgb, LUMA);",
            "float lumaM  = dot(texture2D(texture, vertTexCoord.xy).rgb, LUMA);",
 
            "float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));",
            "float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));",
 
            "vec2 dir = vec2(-((lumaNW + lumaNE) - (lumaSW + lumaSE)), ((lumaNW + lumaSW) - (lumaNE + lumaSE)));",
 
            "float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * REDUCE_MUL), REDUCE_MIN);",
 
            "float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);",
            "dir = min(vec2(SPAN_MAX, SPAN_MAX), max(vec2(-SPAN_MAX, -SPAN_MAX), dir * rcpDirMin)) * texOffset;",
 
            "vec3 rgbA =                      (1.0 / 2.0) * (texture2D(texture, vertTexCoord.xy + dir * (1.0 / 3.0 - 0.5)).rgb + texture2D(texture, vertTexCoord.xy + dir * (2.0 / 3.0 - 0.5)).rgb);",
            "vec3 rgbB = rgbA * (1.0 / 2.0) + (1.0 / 4.0) * (texture2D(texture, vertTexCoord.xy + dir * (0.0 / 3.0 - 0.5)).rgb + texture2D(texture, vertTexCoord.xy + dir * (3.0 / 3.0 - 0.5)).rgb);",
 
            "float lumaB = dot(rgbB, LUMA);",
            "if(lumaB < lumaMin || lumaB > lumaMax)",
                "fragColor = vec4(rgbA, 1.0);",
            "else",
                "fragColor = vec4(rgbB, 1.0);",
 
        "}"
    };
    fxaa = new PShader(this, vertSource, fragSource);
}
 */
