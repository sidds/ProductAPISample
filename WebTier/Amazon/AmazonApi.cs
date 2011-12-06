using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.IO;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.XPath;
using System.Text;
using System.Diagnostics;
using System.Configuration;
using System.Web;
using System.Security.Cryptography;
using WcfProductService;

namespace AmazonApi
{
    public partial class ItemSearchResponse
    {
        public ProductSearchResults ToCanonicalResult()
        {
            ProductSearchResults results = new ProductSearchResults();
            AmazonApi.Items items = this.Items[0];

            results.Valid = Int32.TryParse(items.TotalResults, out results.TotalResults);

            foreach (AmazonApi.Item item in items.Item)
            {
                results.ResultList.Add(item.ToCanonicalResult());
            }

            return results;
        }
    }

    public partial class Item
    {
        public ProductItemResult ToCanonicalResult()
        {
            ProductItemResult result = new ProductItemResult();

            result.ASIN = this.ASIN;
            result.DetailPage = this.DetailPageURL;
            result.Title = this.ItemAttributes.Title;
            result.LowestNewPrice = "";
            result.LowestUsedPrice = "";
            result.ImageUrl = "";

            if ((null != this.ImageSets) && (null != this.ImageSets[0]) && (null != this.ImageSets[0].ImageSet) &&
                (null != this.ImageSets[0].ImageSet[0]) && (null != this.ImageSets[0].ImageSet[0].SmallImage))
            {
                result.ImageUrl = this.ImageSets[0].ImageSet[0].SmallImage.URL;
            }

            if ((null != this.OfferSummary) && (null != this.OfferSummary.LowestNewPrice))
            {
                result.LowestNewPrice = this.OfferSummary.LowestNewPrice.FormattedPrice;
                Int32.TryParse(this.OfferSummary.TotalNew, out result.TotalNew);
            }

            if ((null != this.OfferSummary) && (null != this.OfferSummary.LowestUsedPrice))
            {
                result.LowestUsedPrice = this.OfferSummary.LowestUsedPrice.FormattedPrice;
                Int32.TryParse(this.OfferSummary.TotalUsed, out result.TotalUsed);
            }

            /********* The logic below makes sense if multiple offers were being returned, but as of Nov 11, 2011, Amazon
             * ***** changed its APIs to only return one offer per item.  ***/
            // go thru the offers and try to get the listing id of the lowest offer in each condition category
            int lowestNewPriceAmount = Int32.MaxValue;
            int lowestUsedPriceAmount = Int32.MaxValue;

            if ((null != Offers) && (null != Offers.Offer))
            {
                foreach (AmazonApi.Offer offer in Offers.Offer)
                {
                    if (Condition.New.ToString().Equals(offer.OfferAttributes.Condition))
                    {
                        // go thru each listing and compare price with known lowest new price
                        if ((null != result.LowestNewPrice) && (null != offer.OfferListing)) {
                            foreach (OfferListing listing in offer.OfferListing)
                            {
                                // if (result.LowestNewPrice.Equals(listing.Price.FormattedPrice))
                                int listingAmount;
                                if (Int32.TryParse(listing.Price.Amount, out listingAmount) &&
                                    (lowestNewPriceAmount > listingAmount))
                                {
                                    lowestNewPriceAmount = listingAmount;
                                    result.LowestNewListingId = listing.OfferListingId;
                                    result.LowestNewPrice = listing.Price.FormattedPrice;
                                }
                            }
                         }
                    }
                    else if (Condition.Used.ToString().Equals(offer.OfferAttributes.Condition))
                    {
                        // go thru each listing and compare price with known lowest new price
                        if ((null != result.LowestUsedPrice) && (null != offer.OfferListing))
                        {
                            foreach (OfferListing listing in offer.OfferListing)
                            {
                                // if (result.LowestUsedPrice.Equals(listing.Price.FormattedPrice))
                                int listingAmount;
                                if (Int32.TryParse(listing.Price.Amount, out listingAmount) &&
                                    (lowestUsedPriceAmount > listingAmount))
                                {
                                    lowestUsedPriceAmount = listingAmount;
                                    result.LowestUsedListingId = listing.OfferListingId;
                                    result.LowestUsedPrice = listing.Price.FormattedPrice;
                                }
                            }
                        }
                    } // else
                } // foreach
            } // if

            /****
            // go thru the offers and try to get the listing id of the lowest offer in each condition category
            if ((null != Offers) && (null != Offers.Offer) && (null != Offers.Offer[0]) && (null != Offers.Offer[0].OfferListing))
            {
                OfferListing listing = Offers.Offer[0].OfferListing[0];
                if (null != listing)
                {
                    if (Condition.New.ToString().Equals(Offers.Offer[0].OfferAttributes.Condition))
                    {
                        result.LowestNewListingId = listing.OfferListingId;
                        result.LowestNewPrice = listing.Price.FormattedPrice;
                    }
                    else if (Condition.Used.ToString().Equals(Offers.Offer[0].OfferAttributes.Condition))
                    {
                        result.LowestUsedListingId = listing.OfferListingId;
                        result.LowestUsedPrice = listing.Price.FormattedPrice;
                    }
                }
            }
             * ****/

            return result;
        }
    }

    public partial class CartCreateResponse
    {
        public CartCreateResults ToCanonicalResult()
        {
            CartCreateResults results = new CartCreateResults();
            results.PurchaseUrl = this.Cart[0].PurchaseURL;
            results.CartId = this.Cart[0].CartId;
            return results;
        }
    }

    public class AmazonProvider
    {
        static private string baseApiUrl = "ecs.amazonaws.com";
        static private string baseApiExtension = "/onca/xml";
        static private string apiVersion = "2011-08-01";
        static private string commerceSearchService = "AWSECommerceSearch";
        static private string commerceService = "AWSECommerceService";
        static private string itemSearchOperation = "ItemSearch";
        static private string createCartOperation = "CartCreate";
        private static string ACCOUNT_KEY = "AmazonAccessKey";
        private static string ACCOUNT_SECRET = "AmazonAccessSecret";
        private static string ASSOCIATE_TAG = "AmazonAssociateTag";
        static private string resultSchemaNamespaceRoot = "http://webservices.amazon.com/AWSECommerceService/";

        private string accountKey;
        private string accountSecret;
        private string associateTag;

        private SignedRequestHelper signHelper;

        public AmazonProvider()
        {
            accountKey = ConfigurationManager.AppSettings[ACCOUNT_KEY];
            accountSecret = ConfigurationManager.AppSettings[ACCOUNT_SECRET];
            associateTag = ConfigurationManager.AppSettings[ASSOCIATE_TAG];

            signHelper = new SignedRequestHelper(accountKey, accountSecret, baseApiUrl);
        }

        public ProductSearchResults SearchByKeyword(string searchIndex, string keywords)
        {
            Debug.Assert((null != searchIndex) && (null != keywords));

            // Pass the following standard parameters:
            Dictionary<string, string> parameters = new Dictionary<string, string>();
            parameters.Add("AssociateTag", associateTag);
            parameters.Add("Service", commerceSearchService);
            parameters.Add("Operation", itemSearchOperation);
            parameters.Add("Version", apiVersion);

            // pass these optional parameters (we want prices and images for available products)
            parameters.Add("ResponseGroup", "Large");
            parameters.Add("Availability", "Available");
            parameters.Add("Condition", "All");

            // Pass the user-supplied parameters
            parameters.Add("SearchIndex", searchIndex);

            parameters.Add("Keywords", System.Uri.EscapeDataString(keywords));

            string requestUri = signHelper.Sign(parameters);

            // construct the GET request
            WebRequest getRequest = HttpWebRequest.Create(requestUri);
            HttpWebResponse getResponse = null;
            try
            {
                // send the HTTP GET request
                getResponse = (HttpWebResponse)(getRequest.GetResponse());
            }
            catch (Exception ex)
            {
                // bad HTTP requests will throw an exception
            }

            if (null != getResponse)
            {
                // parse the response (Xml) 
                using (Stream responseStream = getResponse.GetResponseStream())
                {
                    XmlSerializer serializer = new XmlSerializer(typeof(ItemSearchResponse));
                    ItemSearchResponse searchResponse = (ItemSearchResponse)(serializer.Deserialize(responseStream));
                    return searchResponse.ToCanonicalResult();
                }
            }
            else
            {
                // some error -- return invalid search results
                return null;
            }
        }

        public CartCreateResults CreateCart(string listingId, int quantity)
        {
            Debug.Assert(null != listingId); 

            // Pass the following standard parameters:
            Dictionary<string, string> parameters = new Dictionary<string, string>();
            parameters.Add("AssociateTag", associateTag);
            parameters.Add("Service", commerceService);
            parameters.Add("Operation", createCartOperation);
            parameters.Add("Version", apiVersion);

            // pass these optional parameters (we want prices and images for available products)
 
            // Pass the user-supplied parameters
            parameters.Add("Item.1.OfferListingId", listingId);
            parameters.Add("Item.1.Quantity", quantity.ToString());

            string requestUri = signHelper.Sign(parameters);

            // construct the GET request
            WebRequest getRequest = HttpWebRequest.Create(requestUri);
            HttpWebResponse getResponse = null;
            try
            {
                // send the HTTP GET request
                getResponse = (HttpWebResponse)(getRequest.GetResponse());
            }
            catch (Exception ex)
            {
                // bad HTTP requests will throw an exception
            }

            if (null != getResponse)
            {
                // parse the response (Xml) 
                using (Stream responseStream = getResponse.GetResponseStream())
                {
                    XmlSerializer serializer = new XmlSerializer(typeof(CartCreateResponse));
                    CartCreateResponse cartCreateResponse = (CartCreateResponse)(serializer.Deserialize(responseStream));
                    return cartCreateResponse.ToCanonicalResult();
                }
            }
            else
            {
                // some error -- return invalid search results
                return null;
            }
        }

        #region private
        /***
        // manual parsing of xml results --- retire this in favor of automatic desrialization via XSD generated classes
        private AmazonSearchResults getSearchResults(Stream responseStream)
        {
            AmazonSearchResults searchResults = new AmazonSearchResults();

            XPathDocument xpathDoc = new XPathDocument(responseStream);
            XPathNavigator nav = xpathDoc.CreateNavigator();
            XmlNamespaceManager nsMgr = new XmlNamespaceManager(nav.NameTable);

            // TODO: praveen: should programmatically find this default namespace in the doc sent, but for some reason,
            // the code that should do this isn't picking it up.
            nsMgr.AddNamespace("y", resultSchemaNamespaceRoot + apiVersion);

            // find the total number of results
            searchResults.Valid = true;
            // XPathNavigator nav2 = nav.SelectSingleNode("/x:ItemSearchResponse/x:Items/x:TotalResults", nsMgr);
            XPathNavigator nav3 = nav.SelectSingleNode("/y:ItemSearchResponse/y:Items/y:TotalResults", nsMgr);
            if (null != nav3)
            {
                searchResults.TotalResults = (int)(nav3.ValueAs(typeof(System.Int32)));
            }
            nav.MoveToRoot();
            XPathNodeIterator nodeIterator = nav.Select("/y:ItemSearchResponse/y:Items/y:Item", nsMgr);
            while (nodeIterator.MoveNext())
            {
                XPathNavigator itemNav = nodeIterator.Current.Clone();
                searchResults.ResultList.Add(getItemResult(itemNav, nsMgr));
            }
            return searchResults;
        }

        // note: the itemNav must be positioned on an <Item> node
        private AmazonItemResult getItemResult(XPathNavigator itemNav, XmlNamespaceManager nsMgr)
        {
            Debug.Assert(null != itemNav);
            AmazonItemResult itemResult = new AmazonItemResult();
            itemResult.ASIN = itemNav.SelectSingleNode("y:ASIN", nsMgr).Value;
            itemResult.Title = itemNav.SelectSingleNode("y:ItemAttributes/y:Title", nsMgr).Value;
            itemResult.DetailPage = itemNav.SelectSingleNode("y:DetailPageURL", nsMgr).Value;
            return itemResult;
        }
         * ****/
        #endregion

    }

    public class SignedRequestHelper
    {
        private string endPoint;
        private string akid;
        private byte[] secret;
        private HMAC signer;

        private const string REQUEST_URI = "/onca/xml";
        private const string REQUEST_METHOD = "GET";

        //
        //         * Use this constructor to create the object. The AWS credentials are available on
        //         * http://aws.amazon.com
        //         *
        //         * The destination is the service end-point for your application:
        //         *  US: ecs.amazonaws.com
        //         *  JP: ecs.amazonaws.jp
        //         *  UK: ecs.amazonaws.co.uk
        //         *  DE: ecs.amazonaws.de
        //         *  FR: ecs.amazonaws.fr
        //         *  CA: ecs.amazonaws.ca
        //        

        public SignedRequestHelper(string awsAccessKeyId, string awsSecretKey, string destination)
        {
            this.endPoint = destination.ToLower();
            this.akid = awsAccessKeyId;
            this.secret = Encoding.UTF8.GetBytes(awsSecretKey);
            this.signer = new HMACSHA256(this.secret);
        }

        //
        //         * Sign a request in the form of a Dictionary of name-value pairs.
        //         *
        //         * This method returns a complete URL to use. Modifying the returned URL
        //         * in any way invalidates the signature and Amazon will reject the requests.
        //        

        public string Sign(IDictionary<string, string> request)
        {
            // Use a SortedDictionary to get the parameters in naturual byte order, as
            // required by AWS.
            ParamComparer pc = new ParamComparer();
            SortedDictionary<string, string> sortedMap = new SortedDictionary<string, string>(request, pc);

            // Add the AWSAccessKeyId and Timestamp to the requests.
            sortedMap["AWSAccessKeyId"] = this.akid;
            sortedMap["Timestamp"] = this.GetTimestamp();

            // Get the canonical query string
            string canonicalQS = this.ConstructCanonicalQueryString(sortedMap);

            // Derive the bytes needs to be signed.
            StringBuilder builder = new StringBuilder();
            builder.Append(REQUEST_METHOD).Append("\n").Append(this.endPoint).Append("\n").Append(REQUEST_URI).Append("\n").Append(canonicalQS);

            string stringToSign = builder.ToString();
            byte[] toSign = Encoding.UTF8.GetBytes(stringToSign);

            // Compute the signature and convert to Base64.
            byte[] sigBytes = signer.ComputeHash(toSign);
            string signature = Convert.ToBase64String(sigBytes);

            // now construct the complete URL and return to caller.
            StringBuilder qsBuilder = new StringBuilder();
            qsBuilder.Append(" http://").Append(this.endPoint).Append(REQUEST_URI).Append("?").Append(canonicalQS).Append("&Signature=").Append(this.PercentEncodeRfc3986(signature));

            return qsBuilder.ToString();
        }

        //
        //         * Sign a request in the form of a query string.
        //         *
        //         * This method returns a complete URL to use. Modifying the returned URL
        //         * in any way invalidates the signature and Amazon will reject the requests.
        //        

        public string Sign(string queryString)
        {
            IDictionary<string, string> request = this.CreateDictionary(queryString);
            return this.Sign(request);
        }

        //
        //         * Current time in IS0 8601 format as required by Amazon
        //        

        private string GetTimestamp()
        {
            DateTime currentTime = DateTime.UtcNow;
            string timestamp = currentTime.ToString("yyyy-MM-ddTHH:mm:ssZ");
            return timestamp;
        }

        //
        //         * Percent-encode (URL Encode) according to RFC 3986 as required by Amazon.
        //         *
        //         * This is necessary because .NET's HttpUtility.UrlEncode does not encode
        //         * according to the above standard. Also, .NET returns lower-case encoding
        //         * by default and Amazon requires upper-case encoding.
        //        

        private string PercentEncodeRfc3986(string str)
        {
            str = HttpUtility.UrlEncode(str, System.Text.Encoding.UTF8);
            str.Replace("'", "%27").Replace("(", "%28").Replace(")", "%29").Replace("*", "%2A").Replace("!", "%21").Replace("%7e", "~");

            StringBuilder sbuilder = new StringBuilder(str);
            for (int i = 0; i <= sbuilder.Length - 1; i++)
            {
                if (sbuilder[i] == '%')
                {
                    if (Char.IsDigit(sbuilder[i + 1]) && Char.IsLetter(sbuilder[i + 2]))
                    {
                        sbuilder[i + 2] = Char.ToUpper(sbuilder[i + 2]);
                    }
                }
            }
            return sbuilder.ToString();
        }

        //
        //         * Convert a query string to corresponding dictionary of name-value pairs.
        //        

        private IDictionary<string, string> CreateDictionary(string queryString)
        {
            Dictionary<string, string> map = new Dictionary<string, string>();

            string[] requestParams = queryString.Split('&');

            for (int i = 0; i <= requestParams.Length - 1; i++)
            {
                if (requestParams[i].Length < 1)
                {
                    continue;
                }

                char[] sep = { '=' };
                string[] param = requestParams[i].Split(sep, 2);
                for (int j = 0; j <= param.Length - 1; j++)
                {
                    param[j] = HttpUtility.UrlDecode(param[j], System.Text.Encoding.UTF8);
                }
                switch (param.Length)
                {
                    case 1:
                        if (true)
                        {
                            if (requestParams[i].Length >= 1)
                            {
                                if (requestParams[i].ToCharArray()[0] == '=')
                                {
                                    map[""] = param[0];
                                }
                                else
                                {
                                    map[param[0]] = "";
                                }
                            }
                            break; // TODO: might not be correct. Was : Exit Select
                        }

                        break;
                    case 2:
                        if (true)
                        {
                            if (!string.IsNullOrEmpty(param[0]))
                            {
                                map[param[0]] = param[1];
                            }
                        }

                        break; // TODO: might not be correct. Was : Exit Select

                        break;
                }
            }

            return map;
        }

        //
        //         * Consttuct the canonical query string from the sorted parameter map.
        //        

        private string ConstructCanonicalQueryString(SortedDictionary<string, string> sortedParamMap)
        {
            StringBuilder builder = new StringBuilder();

            if (sortedParamMap.Count == 0)
            {
                builder.Append("");
                return builder.ToString();
            }

            foreach (KeyValuePair<string, string> kvp in sortedParamMap)
            {

                builder.Append(this.PercentEncodeRfc3986(kvp.Key));
                builder.Append("=");
                builder.Append(this.PercentEncodeRfc3986(kvp.Value));
                builder.Append("&");
            }
            string canonicalString = builder.ToString();
            canonicalString = canonicalString.Substring(0, canonicalString.Length - 1);
            return canonicalString;
        }
    }

    //
    //     * To help the SortedDictionary order the name-value pairs in the correct way.
    //    

    class ParamComparer : IComparer<string>
    {
        public int Compare(string p1, string p2)
        {

            return string.CompareOrdinal(p1, p2);
        }

    }



}