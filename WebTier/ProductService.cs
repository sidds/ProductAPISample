using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.ServiceModel.Activation;
using System.ServiceModel.Web;
using System.Text;
using System.Diagnostics;
using System.Web;
using System.IO;
using System.Collections.Specialized;
using AmazonApi;

/***
 * This service exposes the following capabilities:
 *   1) send email to a person with a structured message
 *   2) read the reply, parse it, and present it back to the user
 *   3) schedule a meeting with a person (create a Doodle poll, send a structured message, read mail waiting for a reply)
 *   4) call a person with a structured message and get a reply
 * 
 * 
 * ***/

namespace WcfProductService
{
    // Start the service and browse to http://<machine_name>:<port>/Service1/help to view the service's generated help page
    // NOTE: By default, a new instance of the service is created for each call; change the InstanceContextMode to Single if you want
    // a single instance of the service to process all calls.	
    [ServiceContract]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Allowed)]
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single)]
    // NOTE: If the service is renamed, remember to update the global.asax.cs file
    public class ProductService
    {

        AmazonProvider amazonProvider = new AmazonProvider();

        public ProductService()
        {
        }


        [OperationContract]
        [WebInvoke(UriTemplate = "amzn/search", Method = "POST",
                        RequestFormat = WebMessageFormat.Json,
                        ResponseFormat = WebMessageFormat.Json,
                        BodyStyle = WebMessageBodyStyle.Wrapped)]
        public ProductSearchResults Search(string SearchIndex, string Keywords)
        {
            // invoke Amazon API
            return amazonProvider.SearchByKeyword(SearchIndex, Keywords);
        }

        [OperationContract]
        [WebInvoke(UriTemplate = "amzn/cart", Method = "POST",
                        RequestFormat = WebMessageFormat.Json,
                        ResponseFormat = WebMessageFormat.Json,
                        BodyStyle = WebMessageBodyStyle.Wrapped)]
        public CartCreateResults CreateCart(string ListingId, int Quantity)
        {
            // invoke Amazon API
            return amazonProvider.CreateCart(ListingId, Quantity);
        }

    }
}
