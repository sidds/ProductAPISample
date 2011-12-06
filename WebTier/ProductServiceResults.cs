using System;
using System.Collections.Generic;
using System.Text;
using System.Collections.Specialized;

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

    public class ProductItemResult
    {
        public string ASIN;
        
        public string DetailPage;
        public string Title;
        public string ImageUrl;

        public string LowestNewPrice;
        public int    TotalNew;
        public string LowestNewListingId;

        public string LowestUsedPrice;
        public int    TotalUsed;
        public string LowestUsedListingId;
    }

    public class ProductSearchResults
    {
        public bool Valid;
        public int TotalResults;
        public List<ProductItemResult> ResultList;

        public ProductSearchResults()
        {
            ResultList = new List<ProductItemResult>();
            Valid = false;
            TotalResults = 0;
        }
    }

    public class CartCreateResults
    {
        public string PurchaseUrl;
        public string CartId;

        public CartCreateResults()
        {
            PurchaseUrl = null;
            CartId = null;
        }
    }
}