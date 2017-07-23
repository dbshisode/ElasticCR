package com.dee;

import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.InetSocketTransportAddress;
import org.elasticsearch.common.xcontent.XContentBuilder;
import org.elasticsearch.common.xcontent.XContentFactory;
import org.elasticsearch.transport.client.PreBuiltTransportClient;

import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;

import static org.elasticsearch.common.xcontent.XContentFactory.jsonBuilder;

/**
 * Created with IntelliJ IDEA.
 * User: zc1459as
 * Date: 6/30/17
 * Time: 4:23 PM
 * To change this template use File | Settings | File Templates.
 */
public class ESIndex {
    public static int execute(){
        System.out.println("1");
        String img1 = "../../images/prod1.jpg";
        String img2 = "../../images/prod2.jpg";
        String img3 = "../../images/prod3.jpg";
        String img4 = "../../images/prod4.jpg";
        String img5 = "../../images/prod5.jpg";
        String img6 = "../../images/prod6.jpg";
        String[] prod1 = {"XPS", "100","13 inches"};
        String[] prod2 = {"Latitude 3000", "3000","13 inches"};
        String[] prod3 = {"Latitude 5000", "5000","15 inches"};
        String[] prod4 = {"Alienware 13", "GTX 1050"};
        String[] prod5 = {"Alienware 15", "GTX 1060"};
        String[] prod6 = {"Inspiron", "13z"};
        List<String> tagsList1 = new ArrayList<String>();
        tagsList1.add("XPS");
        tagsList1.add("Windows10");
        tagsList1.add("Intel");
        tagsList1.add("128GB:SSD");
        List<String> tagsList2 = new ArrayList<String>();
        tagsList2.add("Latitude");
        tagsList2.add("Windows7");
        tagsList2.add("AMD");
        tagsList2.add("128GB:SSD");
        List<String> tagsList3 = new ArrayList<String>();
        tagsList3.add("Latitude");
        tagsList3.add("Windows10");
        tagsList3.add("Intel");
        tagsList3.add("500GB:HDD");
        List<String> tagsList4 = new ArrayList<String>();
        tagsList4.add("Alienware");
        tagsList4.add("Windows7");
        tagsList4.add("Intel");
        tagsList4.add("1TB:SSD");
        List<String> tagsList5 = new ArrayList<String>();
        tagsList5.add("Alienware");
        tagsList5.add("Windows10");
        tagsList5.add("Intel");
        tagsList5.add("256GB:SSD");
        List<String> tagsList6 = new ArrayList<String>();
        tagsList6.add("Inspiron");
        tagsList6.add("Windows7");
        tagsList6.add("AMD");
        tagsList6.add("256GB:SSD");

        try{
            TransportClient client = new PreBuiltTransportClient(Settings.EMPTY)
                    .addTransportAddress(new InetSocketTransportAddress(new InetSocketAddress("127.0.0.1", 9300)));

        XContentBuilder mappingBuilder = XContentFactory.jsonBuilder()
                .startObject()
                .startObject("properties")
                .startObject("product_family_suggest")
                .field("type", "completion")
                .endObject()
                 .endObject()
                .endObject();

        boolean exists = client.admin().indices()
                    .prepareExists("products")
                    .execute().actionGet().isExists();
        if (!exists){
            client.admin().indices().prepareCreate("products").get();
        }
        client.admin().indices().preparePutMapping("products").setType("info").setSource(mappingBuilder).get();

            IndexResponse response;

            response = client.prepareIndex("products", "info", "1")
                    .setSource(mappingBuilder)
                    .setSource(XContentFactory.jsonBuilder()
                            .startObject()
                            .field("productname", "lappy XPS 100")
                            .field("specifications", "Core i7-2640M, 8GB RAM, 750GB SATA")
                            .field("price", 500)
                            .field("family", "XPS")
                            .field("available_date", "06-01-2017")
                            .field("product_family", prod1)
                            .field("img", img1)
                            .startObject("product_family_suggest").field("input", prod1).endObject()
                            .field("tagsList",tagsList1.toArray())
                            .field("synopsis", "XPS 13: The smallest 13-inch laptop on the planet has the world’s first virtually borderless InfinityEdge display and the latest Intel® processors. Touch, Silver, and Rose Gold options available.")
                            .endObject()
                    )
                    .get();

            response = client.prepareIndex("products", "info", "2")
                    .setSource(XContentFactory.jsonBuilder()
                            .startObject()
                            .field("productname", "Latitude 3000")
                            .field("specifications", "AMD A6-9200 7th Generation, 8GB RAM, 128 GB Solid State Drive")
                            .field("price", 600)
                            .field("family", "Latitude")
                            .field("img", img2)
                            .field("available_date", "03-01-2016")
                            .field("product_family", prod2)
                            .startObject("product_family_suggest").field("input", prod2).endObject()
                            .field("tagsList",tagsList2.toArray())
                            .field("synopsis", "Latitude 3000: Our most secure 15\" mainstream business laptop is now thinner, lighter and beautifully designed, so you can work confidently. Available with Dual Core and Quad Core processors.. Touch, Silver, and Rose Gold options available. AMD A6-9200 7th Generation, 8GB RAM, 750GB SATA")
                            .endObject()
                    )
                    .get();

            response = client.prepareIndex("products", "info", "3")
                    .setSource(XContentFactory.jsonBuilder()
                            .startObject()
                            .field("productname", "lappy Latitude 5000")
                            .field("specifications", "Intel Core i7-2640M, 8GB RAM, 500GB HDD")
                            .field("price", 449)
                            .field("family", "Latitude")
                            .field("available_date", "06-01-2016")
                            .field("product_family", prod3)
                            .field("img", img3)
                            .startObject("product_family_suggest").field("input", prod3).endObject()
                            .field("tagsList",tagsList3.toArray())
                            .field("synopsis", "XPS 13: The smallest 13-inch laptop on the planet has the world’s first virtually borderless InfinityEdge display and the latest Intel® processors. Touch, Silver, and Rose Gold options available. Intel Core i7-2640M, 8GB RAM, 500GB HDD")
                            .endObject()
                    )
                    .get();

            response = client.prepareIndex("products", "info", "4")
                    .setSource(XContentFactory.jsonBuilder()
                            .startObject()
                            .field("productname", "Alienware 13")
                            .field("specifications", "Intel® Core™ i7-7700HQ, 32GB DDR4, 256 GB Solid State Drive,13 Inch Monitor")
                            .field("price", 1000)
                            .field("family", "Alienware")
                            .field("img", img4)
                            .field("available_date", "01-01-2017")
                            .field("product_family", prod4)
                            .startObject("product_family_suggest").field("input", prod4).endObject()
                            .field("tagsList",tagsList4.toArray())
                            .field("synopsis", "XPS 13: The smallest 13-inch laptop on the planet has the world’s first virtually borderless InfinityEdge display and the latest Intel® processors. Touch, Silver, and Rose Gold options available. Intel® Core™ i7-7700HQ, 32GB DDR4, 500GB Solid State Drive,13 Inch Monitor")
                            .endObject()
                    )
                    .get();

            response = client.prepareIndex("products", "info", "5")
                    .setSource(XContentFactory.jsonBuilder()
                            .startObject()
                            .field("productname", "Alienware 15")
                            .field("specifications", "Intel® Core™ i7-7700HQ, 32GB DDR4, 1 TB Solid State Drive,15 Inch Monitor")
                            .field("price", 1200)
                            .field("family", "Alienware")
                            .field("product_family", prod5)
                            .field("img", img5)
                            .field("available_date", "06-01-2018")
                            .startObject("product_family_suggest").field("input", prod5).endObject()
                            .field("tagsList",tagsList5.toArray())
                            .field("synopsis", "Customizable: With the addition of the NVIDIA Pascal GPU's and the latest generation of Intel® processors, the Alienware 13 is capable of producing high-end experiences. Intel® Core™ i7-7700HQ, 32GB DDR4, 1TB Solid State Drive,15 Inch Monitor.")
                            .endObject()
                    )
                    .get();

            response = client.prepareIndex("products", "info", "6")
                    .setSource(XContentFactory.jsonBuilder()
                            .startObject()
                            .field("productname", "Inspiron 13Z")
                            .field("specifications", "AMD A6-9200 7th Generation, 256 GB Solid State Drive, 4GB, 2400MHz, DDR4; up to 16GB")
                            .field("price", 400)
                            .field("family", "Inspiron")
                            .field("product_family", prod6)
                            .field("img", img6)
                            .field("available_date", "06-01-2016")
                            .startObject("product_family_suggest").field("input", prod6).endObject()
                            .field("tagsList",tagsList6.toArray())
                            .field("synopsis", "Experience faster computing and multitasking with the power of the AMD A6 quad-core processor, Windows 10 Home and plenty of memory. AMD A6-9200 7th Generation AMD A6-9200, 4GB, 2400MHz, DDR4; up to 16GB 256 GB Solid State Drive")
                            .endObject()
                    )
                    .get();
            return 0;
        }catch(Exception E){
            System.out.println("E:"+E);
            return 1;
        }
    }
}
