<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript" src="../../Scripts/JSONHelp.js"></script>
    <script type="text/javascript" src="http://oauth.googlecode.com/svn/code/javascript/oauth.js"></script>
    <script type="text/javascript" src="http://oauth.googlecode.com/svn/code/javascript/sha1.js"></script>
    <script type="text/javascript">

        $(function () {
        });

    // pretty printer for categories results
    function printCategoryToHTML(category) {
        var printString = "";
        if (null == category) {
            return printString;
        }
        if (typeof category == 'object') {
            var nameValue = null;
	    var categoriesValue = null;
            $.each(category, function (key, value) {
                if (key == 'name') {
                    nameValue = value;
                }
                else if (key == 'subCategories') {
                    categoriesValue = value;
                }
            });

            if (null != nameValue) {
                printString += '<li>' + nameValue +
                                '&nbsp;&nbsp;&nbsp;&nbsp;' +
                                '</li>';
            }
            if (null != categoriesValue) {
                printString += printCategoriesToHTML(categoriesValue);
            }
        }
        return printString;
    };

    // pretty printer for categories results
    function printCategoriesToHTML(categories) {
        var printString = "";
        if (null == categories) {
            return printString;
        }
        if (typeof categories == 'object') {
            // this should be an array of categories 
            printString += "<ul>";
            $.each(categories, function (key, value) {
                printString += printCategoryToHTML(value);
            });
            printString += "</ul>";
        }
        return printString;
    };


        function ShowCategories(JSONdata) {
            alert($.printableJSON(JSONdata, 0));
    	    if (null == JSONdata.error) {
	        $("#ResultsDiv").append(printCategoriesToHTML(JSONdata.categories));
	    }
	    else {
	        $("#ResultsDiv").append($.printJSONToHTML(JSONdata, 0));
            }
            $("#ResultsDiv")[0].style.display = "";
	    };


        function GetCategories() {
	    // implemented in a cleaner separate url and parameters style
	    var requestData = {
		'apiKey': '<%:ViewData["BBYApiKey"]%>',
        'format': 'json'
	    };

	    $.getJSON('<%:ViewData["BBYOpenUri"]%>/categories?callback=?', requestData, ShowCategories);
	};


        function purchaseProduct(addToCartUrl) {
            // alert("Purchase Product Id: " + listingId);
            window.open(addToCartUrl, "BestBuyPurchaseWindow");
        };

        function clearSearchResults() {
            // $("#ResultsDiv")[0].style.display = "none";
            $("#TotalResults").contents().remove();
            $("#ResultsBody").children().remove();
        };

        function makeBuyButtonHTML(buttonText, productId, addToCartUrl) {
            if (null == productId) {
                return "";
            }
            else {
                return '<button name="Buy' + productId + '" onclick="purchaseProduct(\'' + addToCartUrl + '\');">' + buttonText + '</button>';
            }
        };

        function showSearchResults(JSONdata) {

            // alert($.printableJSON(JSONdata, 0));

            var searchResult = JSONdata;

            if ((null == searchResult) || (typeof searchResult != 'object')) {
                alert("Null object");
                return;
            }

            $("#TotalResults").append(searchResult.total);
            $("#ResultsDiv")[0].style.display = "";

            for (var i in searchResult.products) {
                var newRow = '<tr name="ResultRow">';
                var result = searchResult.products[i];
                if (null != result) {
                    var isAvailable = ((result.inStoreAvailability != "false") || (result.onlineAvailability != "false"));
                    // alert("Result = " + $.printableJSON(result, 0));
                    // newRow += '<td>' + result.productId + '</td>';
                    newRow += '<td><image src="' + result.thumbnailImage + '"/></td>';
                    newRow += '<td>' + result.condition + '</td>';
                    newRow += '<td>' + result.salePrice + '</td>';
                    newRow += '<td>' + result.customerReviewAverage + '</td>';
                    newRow += '<td>' + result.onlineAvailability + '</td>';
                    newRow += '<td>' + result.inStoreAvailability + '</td>';
                    newRow += '<td>' + result.name + '</td>';
                    newRow += '<td><a href="' + result.url + '" target="_blank">Product Details</a></td>';
                    newRow += '<td>' + (isAvailable ? makeBuyButtonHTML('Buy', result.productId, result.addToCartUrl) : '') + '</td>';
                    newRow += '</tr>';
                    $("#ResultsBody").append(newRow);
                }
            }

        };

        function ShowResponse(JSONdata) {
            alert($.printableJSON(JSONdata, 0));
            // $("#results").html($.printJSONToHTML(JSONdata, 0));
        };

        function SearchProductsByAttribute(category, colors, minReviewAvg, searchTerm) {
            clearSearchResults();
            var requestData = {
		        'apiKey': '<%:ViewData["BBYApiKey"]%>',
                'format': 'json',
                'sort' : 'salePrice.asc'
	    };
	    var queryString = '(';
	    var numQueryConditions = 0;

	    if (null != category) {
		queryString += ((numQueryConditions > 0)? '&' : '');
		queryString += 'categoryPath.name=' + category;
		numQueryConditions++;
	    };
	    if (null != colors) {
		queryString += ((numQueryConditions > 0)? '&' : '');
		queryString += 'color in(' + colors + ')';
		numQueryConditions++;
	    }
	    if (null != minReviewAvg) {
		queryString += ((numQueryConditions > 0)? '&' : '');
		queryString += 'customerReviewAverage>' + minReviewAvg;
		numQueryConditions++;
	    }
	    if (null != searchTerm) {
		queryString += ((numQueryConditions > 0)? '&' : '');
		queryString += 'search=' + searchTerm;
		numQueryConditions++;
	    }
	    queryString += ')';

	    $.getJSON('<%:ViewData["BBYOpenUri"]%>/products' + queryString + '?callback=?', requestData, showSearchResults);
	};

    </script>
    <div id="SearchAPI" style="display: block">
        <script type="text/javascript">
            function GetCategory(form) {
                var i;
                for (i = 0; i < form.Category.length; i++) {
                    if (form.Category[i].checked) {
                        break;
                    }
                }
                return form.Category[i].value + '*';
            };
            // colors can be multi-selected
            function GetColor(form) {
                var returnColors = null;
                var i;
                for (i = 0; i < form.Color.length; i++) {
                    if (form.Color[i].checked) {
                        if (null == returnColors) {
                            returnColors = form.Color[i].value;
                        }
                        else {
                            returnColors = returnColors + ',' + form.Color[i].value;
                        }
                    }
                }
                return returnColors;
            };
        </script>
        <p>
            This sample shows how to access information in the BestBuy BBYOPEN API which exposes
            the product, price, review and store information. Additionally, there is a commerce
            API in beta (by invitation only) that allows for e-commerce (purchase and fulfilment)
            via API calls. The developer site is <a href="http://bbyopen.com">here</a>. Terms
            of usage are <a href="https://bbyopen.com/bbyopen-terms-service">here</a>. There
            are limits of 5 cals per second and 50000 calls per day. Very interestingly, they
            also provide daily "archives" that can be used for information that isn't so real-time-sensitive.
            This drastically cuts down on the need to use the API for things like store information
            (apparently this is what they do to populate Google shopping). There is also an
            Affiliate program that allows the publisher (like this application) to get paid
            if the user makes a purchase on bestbuy.com. While proper use of the API would involve
            a bunch of this happening at the server-side, this prototype is entirely Javascript
            on the client.
        </p>
        <table>
            <thead>
                <tr>
                    <td>
                        Categories
                    </td>
                    <td>
                        Search the online store
                    </td>
                    <td>
                        Search in physical stores
                    </td>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>
                        Categories are organized in a multi-level hierarchy. Each category result has a
                        title and a hierarchy path. Since each call ony returns 10 results (with a link
                        to the next page), the category hierarchy is not complete. It needs to be reconstrucuted
                        as a tree for pretty printing (have not done that here).
                        <form action="BestBuy.aspx">
                        <input type="button" value="Get Categories" onclick="GetCategories();" />
                        </form>
                    </td>
                    <td>
                        There are a large number of attributes that can be queried. Here are just a few
                        examples ...
                        <form action="BestBuy.aspx">
                        <input type="radio" name="Category" value="Cameras" checked="1" />
                        Cameras
                        <br />
                        <input type="radio" name="Category" value="Accessories" />
                        Accesories
                        <br />
                        <input type="radio" name="Computers" value="Computers & Tablets" />
                        Computers & Tablets
                        <br />
                        <input type="radio" name="Category" value="TV" />
                        TV and Video
                        <br />
                        <input type="radio" name="Category" value="Her" />
                        Gifts For Her
                        <br />
                        <input type="radio" name="Category" value="Him" />
                        Gifts For Him
                        <br />
                        <hr />
                        <input type="checkbox" name="Color" value="black" />
                        black
                        <br />
                        <input type="checkbox" name="Color" value="white" checked="1"/>
                        white
                        <br />
                        <input type="checkbox" name="Color" value="silver" checked="1" />
                        silver
                        <br />
                        <hr />
                        Min Review Average :
                        <input type="text" name="MinReviewAverage" value="3.5" />
                        <br />
                        Search term :
                        <input type="text" name="SearchTerm" value="digital camera" />
                        <br />
                        <input type="button" value="Search" onclick="SearchProductsByAttribute(GetCategory(this.form), GetColor(this.form), this.form.MinReviewAverage.value, this.form.SearchTerm.value);" />
                        </form>
                    </td>
                    <td>
                    Will fill this in with queries over physical BestBuy stores
                    </td>
                </tr>
            </tbody>
        </table>
        <p />
        <h2>
            Results</h2>
        <div id="ResultsDiv" style="display: none">
            Total Results = <span id="TotalResults"></span>
            <table>
                <thead>
                    <tr>
                        <td>
                            Image
                        </td>
                        <td>
                            Condition
                        </td>
                        <td>
                            Price
                        </td>
                        <td>
                            Avg Review
                        </td>
                        <td>
                            Online
                        </td>
                        <td>
                            In-Store
                        </td>
                        <td>
                            Title
                        </td>
                        <td>
                            Details
                        </td>
                    </tr>
                </thead>
                <tbody id="ResultsBody">
                </tbody>
            </table>
        </div>
</asp:Content>
