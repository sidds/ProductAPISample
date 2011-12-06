<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript" src="../../Scripts/JSONHelp.js"></script>
    <script type="text/javascript" src="http://oauth.googlecode.com/svn/code/javascript/oauth.js"></script>
    <script type="text/javascript" src="http://oauth.googlecode.com/svn/code/javascript/sha1.js"></script>
    <script type="text/javascript">

        $(function () {
        });

        function createCartResponse(JSONdata) {
            var createCartResult = JSONdata.CreateCartResult;

            // alert("Received cart response. CartId = " + createCartResult.CartId + ", PurchaseUrl = " + createCartResult.PurchaseUrl);
            window.open(createCartResult.PurchaseUrl, "AmazonPurchaseWindow");
        };

        function purchaseProduct(listingId) {
            // alert("Purchase Product Id: " + listingId);
            var dataToPost = { ListingId : listingId,
                               Quantity: '1'
                            };
            $.postJSON("../Product/amzn/cart", dataToPost, createCartResponse);
        };

        function clearSearchResults() {
            // $("#ResultsDiv")[0].style.display = "none";
            $("#TotalResults").contents().remove();
            $("#ResultsBody").children().remove();
        };

        function makeBuyButtonHTML(buttonText, listingId) {
            if (null == listingId) {
                return "";
            }
            else {
                return '<button name="Buy' + listingId + '" onclick="purchaseProduct(\'' + listingId + '\');">' + buttonText + '</button>';
            }
        };

        function showSearchResults(JSONdata) {

            clearSearchResults();
            // alert($.printableJSON(JSONdata, 0));

            var searchResult = JSONdata.SearchResult;

            if ((null == searchResult) || (typeof searchResult != 'object')) {
                alert("Null object");
                return;
            }

            $("#TotalResults").append(searchResult.TotalResults);
            $("#ResultsDiv")[0].style.display = "";

            for (var i in searchResult.ResultList) {
                var newRow = '<tr name="ResultRow">';
                var result = searchResult.ResultList[i];
                if (null != result) {
                    // alert("Result = " + $.printableJSON(result, 0));
                    newRow += '<td>' + result.ASIN + '</td>';
                    newRow += '<td><image src="' + result.ImageUrl + '"/></td>';
                    newRow += '<td>' + result.TotalNew + ' items starting at ' + result.LowestNewPrice + '</td>';
                    newRow += '<td>' + result.TotalUsed + ' items starting at ' + result.LowestUsedPrice + '</td>';
                    newRow += '<td>' + result.Title + '</td>';
                    newRow += '<td><a href="' + result.DetailPage + '" target="_blank">Product Details</a></td>';
                    newRow += '<td>' + makeBuyButtonHTML('Buy New', result.LowestNewListingId) + '</td>';
                    newRow += '<td>' + makeBuyButtonHTML('Buy Used', result.LowestUsedListingId) + '</td>';
                    newRow += '</tr>';
                    $("#ResultsBody").append(newRow);
                }
            }

        };

        function ShowResponse(JSONdata) {
            alert($.printableJSON(JSONdata, 0));
            // $("#results").html($.printJSONToHTML(JSONdata, 0));
        };

        function SearchByKeyword(productType, searchTerm) {
	        // alert("Post productType: " + productType + " , searchTerm: " + searchTerm);
	        var dataToPost = { SearchIndex: productType, 
			                   Keywords: searchTerm };
			$.postJSON("../Product/amzn/search", dataToPost, showSearchResults);
        };


    </script>

     <div id="SearchAPI" style="display:block">
                <script type="text/javascript">
                    function GetProductType(form) {
                        var i;
                        for (i = 0; i < form.ProductType.length; i++) {
                            if (form.ProductType[i].checked) {
                                break;
                            }
                        }
                        return form.ProductType[i].value;
                    };
                    // yelp types/categories can be multi-selected
                    function GetType(form) {
                        var returnTypes = null;
                        var i;
                        for (i = 0; i < form.Types.length; i++) {
                            if (form.Types[i].checked) {
                                if (null == returnTypes) {
                                    returnTypes = form.Types[i].value;
                                }
                                else {
                                    returnTypes = returnTypes + ',' + form.Types[i].value;
                                }
                            }
                        }
                        return returnTypes;
                    };
                </script>
     <table>
        <thead>
            <tr>
            <td> Description </td>
            <td>Search by product type</td>
            </tr>
        </thead>
        <tbody>
        <tr>
            <td>
    <p>
        This sample shows how to access information in the Amazon Product Advertising API which is part of the Amazon affiliates program. 
        The developer site is <a href="https://affiliate-program.amazon.com/gp/advertising/api/detail/main.htm">here</a>.
        Terms of usage are <a href="http://affiliate-program.amazon.com/gp/advertising/api/detail/agreement.html/ref=amb_link_83952631_8?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=assoc-center-1&pf_rd_r=&pf_rd_t=501&pf_rd_p=&pf_rd_i=assoc-api-detail-0">here</a>. 
     </p>
     <p>
        The API allows a third-party app to build a webstore that exposes the Amazon inventory, and utilizes Amazon features like product search, product reviews, seller reviews, etc. Describe limits and highlights here.
     </p>
     <p>
     Of particular interest, .....
     </p>
            </td>
            <td>
                <form action="Amazon.aspx">
                    <input type="radio" name="ProductType" value="Books"checked="true"/> Books<br />
                    <input type="radio" name="ProductType" value="Music"/> Music <br />
                    <input type="radio" name="ProductType" value="DVD"/> DVD <br />
                    <input type="radio" name="ProductType" value="Video"/> Video <br />
                    <input type="radio" name="ProductType" value="Electronics"/> Electronics <br />
                    <input type="radio" name="ProductType" value="Watch"/> Watch <br />
                    <input type="radio" name="ProductType" value="Jewelry"/> Jewelry <br />
                    <input type="radio" name="ProductType" value="Apparel"/> Apparel <br />
                    <input type="radio" name="ProductType" value="Toys"/> Toys <br />
                    <input type="radio" name="ProductType" value="Automotive"/> Automotive <br />
                    <hr />

                    Search term : <input type="text" name="SearchTerm" value="harry potter"/> <br />
                    
                    <input type="button" value="Search" onclick="SearchByKeyword(GetProductType(this.form), this.form.SearchTerm.value);" />
                </form> 
            </td>          
        </tr>
        </tbody>
     </table>
     </div>
     <div id="BusinessAPI" style="display:none">
     <h2> Business API </h2>
     TODO. Given a business id (from a search result), the business API provides details of the business, reviews, and ratings.
     </div>

     <p/>
     <h2>Results</h2>
     
     <div id="ResultsDiv" style="display:none">
        Total Results = <span id="TotalResults"></span>
        <table>
            <thead>
                <tr>
                    <td>ASIN</td>
                    <td>Image</td>
                    <td>New</td>
                    <td>Used</td>
                    <td>Title</td>
                    <td>Details</td>
                </tr>
            </thead>
            <tbody id="ResultsBody">
            </tbody>
        </table>
     </div>
    
</asp:Content>
