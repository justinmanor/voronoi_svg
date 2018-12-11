import megamu.mesh.*;
  
PShape s;
PShape dot, dot2;
float[][]  verts = new float[18049][2];
float[][] myEdges;
MPolygon[] myRegions;
  
void setup() {
  size(5000, 2000);
  //initFXAA();
  //smooth(32);
  pixelDensity(2);
  s = loadShape("GradLabs_blur_mod.svg");
  
  int count = s.getChildCount();
  println("Count = " + count);
  dot = s.getChild(0);
  //int vcount = dot.getVertexCount();
  //println("vert count = " + vcount);
  
  
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
  //myEdges = myVoronoi.getEdges();
  
  strokeWeight(1.0);
  
  //drawNetwork();
  drawRegions();
}

void drawNetwork() {
  background(200);
  //shape(s, 0, 0, 2000, 700);
  
  float scale = 6.5;
    strokeWeight(1.0);
  for(int i=0; i<myEdges.length; i++) {
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    
    //if (sqrt((endX - startX)*(endX - startX) + (endY - startY)*(endY - startY)) < 20.0)  
      line( scale*startX, scale*startY, scale*endX, scale*endY );
  }
    strokeWeight(2.0);
  for(int i=0; i<myEdges.length; i++) {
    float startX = myEdges[i][0];
    float startY = myEdges[i][1];
    float endX = myEdges[i][2];
    float endY = myEdges[i][3];
    
      stroke(200);
      fill(0);
      ellipse( scale*startX, scale*startY, 7,7);
      ellipse( scale*endX, scale*endY,7,7 );
  }
}

void drawRegions() {
  //  scale(6.5);
  background(255);
  strokeWeight(1.5);
  stroke(255);
  for(int i=0; i<myRegions.length; i++)
  {
    pushMatrix();
    if (i%100 == 0) println(i);
    // an array of points
    float[][] regionCoordinates = myRegions[i].getCoords();

    fill(0);
    scale(3.0);
    myRegions[i].draw(this); // draw this shape
    popMatrix();
  }
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
