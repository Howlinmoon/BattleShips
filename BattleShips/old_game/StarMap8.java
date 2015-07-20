import java.applet.Applet;
import java.awt.*;
import java.util.*;
import java.io.*;
import java.net.*;

public class StarMap8 extends Applet {


URL StarMapURL;

public void init()
{
       String s1 = "http://204.210.200.63:4080/game_design/starmap.data";
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
        String planetXcoord,planetYcoord,starXcoord,starYcoord;
        int ordinate;

        int mapx1,mapx2,mapy1,mapy2,xdist,ydist,gridsize,planetoffset;
        int number_planets = 10000;
        int number_stars = 500;
        double ActualValueX,ActualValueY,ScaledValueX,ScaledValueY;
        double ScaleValue;
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
        ScaleValue = (xdist / 2.0)/16850000000.0;

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
       String objects = "planets"; 
       i = 0;
       System.out.println("StarMap8");
                        try
                        {
                        String inputLine;
                        String temp;
                        StarMapURL.openConnection();
                        DataInputStream in = new DataInputStream(
                             new BufferedInputStream(StarMapURL.openStream()));
                             while ((temp = in.readLine()) != null)
                             {
                                  if (temp.equals("stars") )
                                     {
                                     temp = in.readLine();
                                     objects = "stars";
                                     i = 0;
                                     System.out.println("switching to stars");
                                     }

                                if (objects.equals("planets") )
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

                                   planetxx[i] = (int) (ScaledValueX + (xdist / 2.0) );
                                   planetyy[i] = (int) (ScaledValueY + (xdist / 2.0) );
                                   }
                                   number_planets = i; 
                                }

                                if (objects.equals("stars") )
                                {
                                  i++;
                                  my_param = temp;
                                  coordpair = new StringTokenizer(my_param,",");
                                  while (coordpair.hasMoreTokens())
                                  {
                                   starXcoord = coordpair.nextToken();
                                   starYcoord = coordpair.nextToken();
                                   starx[i] = Long.valueOf(starXcoord).longValue();
                                   stary[i] = Long.valueOf(starYcoord).longValue();

                                   ActualValueX =  starx[i];
                                   ActualValueY =  stary[i];
                                   ScaledValueX = ActualValueX * ScaleValue;
                                   ScaledValueY = ActualValueY * ScaleValue;

                                   starxx[i] = (int) (ScaledValueX + (xdist / 2.0) );
                                   staryy[i] = (int) (ScaledValueY + (xdist / 2.0) );
                                   }
                                number_stars = i;
                                }
                             }
                        System.out.println("A total of "+number_planets+" planets read");
                        System.out.println("A total of "+number_stars+" stars read");
                        }
          
                        catch (IOException e)
                        {
                         System.err.println("Woof! "+e);
                        }

          g.setColor(Color.yellow);
        for (i = 1; i<= number_stars; i++)
               {
                g.fillOval((starxx[i]-(starscale/2)),(staryy[i]-(starscale/2)),starscale,starscale);
               }

            g.setColor(Color.green);
                
                for (i = 1; i<= number_planets; i++)
                    {
                        g.fillOval((planetxx[i]-(planetscale/2)),(planetyy[i]-(planetscale/2)),planetscale,planetscale);
                    }                
           }
 }

