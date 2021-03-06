/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package org.superbiz;

import java.net.URL
import javax.ws.rs.core.MediaType
import org.apache.cxf.jaxrs.client.WebClient
import org.jboss.arquillian.container.test.api.Deployment
import org.jboss.arquillian.junit.Arquillian
import org.jboss.arquillian.test.api.ArquillianResource
import org.jboss.shrinkwrap.api.ShrinkWrap
import org.jboss.shrinkwrap.api.spec.WebArchive
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

/**
 * Arquillian will start the container, deploy all @Deployment bundles, then run all the @Test methods.
 *
 * A strong value-add for Arquillian is that the test is abstracted from the server.
 * It is possible to rerun the same test against multiple adapters or server configurations.
 *
 * A second value-add is it is possible to build WebArchives that are slim and trim and therefore
 * isolate the functionality being tested.  This also makes it easier to swap out one implementation
 * of a class for another allowing for easy mocking.
 *
 */
@RunWith(typeof(Arquillian))
class ColorServiceTest {

    /**
     * ShrinkWrap is used to create a war file on the fly.
     *
     * The API is quite expressive and can build any possible
     * flavor of war file.  It can quite easily return a rebuilt
     * war file as well.
     *
     * More than one @Deployment method is allowed.
     */
    @Deployment
    def static WebArchive createDeployment() {
        return ShrinkWrap.create(typeof(WebArchive)).addClasses(typeof(ColorService), typeof(Color));
    }

    /**
     * This URL will contain the following URL data
     *
     *  - http://<host>:<port>/<webapp>/
     *
     * This allows the test itself to be agnostic of server information or even
     * the name of the webapp
     *
     */
    @ArquillianResource
    private URL webappUrl;


    @Test
    def postAndGet() throws Exception {

        // POST
        val webClient = WebClient.create(webappUrl.toURI());
        val response = webClient.path("color/green").post(null);

        assertEquals(204, response.getStatus());

        // GET
        val webClient2 = WebClient.create(webappUrl.toURI());
        val content = webClient2.path("color").get(typeof(String));

        assertEquals("green", content);

    }

    @Test
    def getColorObject() throws Exception {

        val webClient = WebClient.create(webappUrl.toURI());
        webClient.accept(MediaType.APPLICATION_JSON);

        val color = webClient.path("color/object").get(typeof(Color));

        assertNotNull(color);
        assertEquals("orange", color.getName());
        assertEquals(0xE7, color.getR());
        assertEquals(0x71, color.getG());
        assertEquals(0x00, color.getB());
    }
}
