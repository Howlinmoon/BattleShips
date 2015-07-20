import java.applet.Applet;
import java.awt.*;
import java.util.*;
import java.io.*;
import java.net.*;

public class StarMap7 extends Applet {


URL StarMapURL;

public void init()
{
       String s1 = "http://beholder.dhs.org:4080/game_design/starmap.data";
                        try
                        {
                                StarMapURL = new URL(s1);
                        } catch (MalformedURLException e){};
}

        public void paint(Graphics g) {
        int i,j,planets,stars,planetscale,starscale;
        long tempx,tempy,junk;
        double junk2;
        
        String pscale,sscale,gridX1,gridX2,gridY1,gridY2,gridsiz,plntoff;
        String planetXcoord,planetYcoord;
        int ordinate;

        int mapx1,mapx2,mapy1,mapy2,xdist,ydist,gridsize,planetoffset;
        int number_planets = 10000;
        int number_stars = 500;
        double ActualValueX,ActualValueY,ScaledValueX,ScaledValueY;
        double ScaleValue = 250.0/16850000000.0;
        String thisLine;

        pscale = getParameter("planetscale");
        planetscale = Integer.valueOf(pscale).intValue();

        sscale = getParameter("starscale");
        starscale = Integer.valueOf(sscale).intValue();

        long[] planetx,planety,starx,stary;
        planetx = new long[number_planets];
        planety = new long[number_planets];
        starx = new long[number_stars];
        stary = new long[number_stars];
        int[] planetxx,planetyy,starxx,staryy;
        planetxx = new int[number_planets];
        planetyy = new int[number_planets];
        starxx = new int[number_stars];
        staryy = new int[number_stars];

        gridX1 = getParameter("mapx1");
        mapx1 = Integer.valueOf(gridX1).intValue();
        gridX2 = getParameter("mapx2");
        mapx2 = Integer.valueOf(gridX2).intValue();
        gridY1 = getParameter("mapy1");
        mapy1 = Integer.valueOf(gridY1).intValue();
        gridY2 = getParameter("mapy2");
        mapy2 = Integer.valueOf(gridY2).intValue();

        xdist = mapx2 - mapx1;
        ydist = mapy2 - mapy1;

        gridsiz = getParameter("gridsize");
        gridsize = Integer.valueOf(gridsiz).intValue();

        plntoff = getParameter("planetoffset");
        planetoffset = Integer.valueOf(plntoff).intValue();


        g.setColor(Color.black);
        g.fillRect(mapx1,mapy1,xdist,ydist);

        g.setColor(Color.white);

     for (j = mapx1; j <= mapx2; j = j + gridsize) {
        for (i = mapy1; i<= mapy2; i = i + gridsize) {

                g.drawLine(j,i,j,i+gridsize);
                }
             }
     for (i = mapy1; i <= mapy2; i = i + gridsize) {
        for (j = mapx1; j <= mapx2; j = j + gridsize) {
                g.drawLine(j,i,j+gridsize,i);
                }
          }

        g.drawLine(mapx1,mapy2-1,mapx2-1,mapy2-1);
        g.drawLine(mapx2-1,mapx1-1,mapx2-1,mapy2-1);


       StringTokenizer coordpair;
       String my_param;
       i = 0;
       System.out.println("StarMap77");
                        try
                        {
                        String inputLine;
                        String temp;
                        StarMapURL.openConnection();
                        DataInputStream in = new DataInputStream(
                                new BufferedInputStream(StarMapURL.openStream()));
                                while ((temp = in.readLine()) != null)
                                {
                                  i++;
                                  my_param = temp;
                                  coordpair = new StringTokenizer(my_param,",");
                                  while (coordpair.hasMoreTokens())
                                  {
                                   planetXcoord = coordpair.nextToken();
                                   planetYcoord = coordpair.nextToken();
                                   planetx[i] = Long.valueOf(planetXcoord).longValue();
                                   planety[i] = Long.valueOf(planetYcoord).longValue();

                                   ActualValueX =  planetx[i];
                                   ActualValueY =  planety[i];
                                   ScaledValueX = ActualValueX * ScaleValue;
                                   ScaledValueY = ActualValueY * ScaleValue;

                                   planetxx[i] = (int) ScaledValueX + 250;
                                   planetyy[i] = (int) ScaledValueY + 250;
//                                   System.out.println("PlanetX["+i+"] (Scaled) = "+ScaledValueX+" Planety["+i+"] (Scaled) = "+ScaledValueY);
                                   }
//                                  System.out.print(i);
                                  }
                      number_planets = i; 
                        System.out.println("A total of "+number_planets+" planets read");
                        }
          
                        catch (IOException e)
                        {
                         System.err.println("Woof! "+e);
                        }

//        for (stars = 1; stars <=5 ; stars++)
//               {
//               junk2 = Math.random()*mapx2;
//               tempx = (int) junk2;
//               starx[stars] = tempx;
//               junk2 = Math.random()*mapy2;
//               tempy = (int) junk2;
//               stary[stars] = tempy;
//                g.setColor(Color.yellow);
//                g.fillOval((starx[stars]-(starscale/2)),(stary[stars]-(starscale/2)),starscale,starscale);
//                }

            g.setColor(Color.green);
                
                for (i = 1; i<= number_planets; i++)
                    {
                        g.fillOval((planetxx[i]-(planetscale/2)),(planetyy[i]-(planetscale/2)),planetscale,planetscale);
                    }                
           }
 }

