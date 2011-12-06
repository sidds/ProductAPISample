<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript" src="../Scripts/JSONHelp.js"></script>
    <script type="text/javascript">

    $(function () {
    });

    function ShowResponse(JSONdata) {
        $("#results").html($.printJSONToHTML(JSONdata, 0));
    };

    // pretty printer for categories results
    function printCategoryToHTML(JSONObject) {
        var printString = "";
        if (null == JSONObject) {
            return printString;
        }
        if (typeof JSONObject == 'object') {
            var shortNameValue = null;
            var iconValue = null;
            var categoriesValue = null;
            var idValue = null;
            $.each(JSONObject, function (key, value) {
                if (key == 'icon') {
                    iconValue = value;
                }
                else if (key == 'shortName') {
                    shortNameValue = value;
                }
                else if (key == 'categories') {
                    categoriesValue = value;
                }
                else if (key == 'id') {
                    idValue = value;
                }
                else if (typeof key == 'number') {
                    // recursively print
                    printString += printCategoryToHTML(value);
                }
            });

            if ((null != shortNameValue) && (null != iconValue) && (null != idValue)) {
                var iconUrl = iconValue.prefix + iconValue.sizes[0] + iconValue.name;
                printString += '<li>' + shortNameValue +
                                '(' + idValue + ')' + '&nbsp;&nbsp;&nbsp;&nbsp;' +
                                 '<img src="' + iconUrl + '"></img>' + 
                                '</li>';
            }
            if (null != categoriesValue) {
                // traverse down without printing this key
                printString += printCategoriesToHTML(categoriesValue);
            }
        }
        return printString;
    };

    // pretty printer for categories results
    function printCategoriesToHTML(JSONObject) {
        var printString = "";
        if (null == JSONObject) {
            return printString;
        }
        if (typeof JSONObject == 'object') {
            // this should be an array of categories 
            printString += "<ul>";
            $.each(JSONObject, function (key, value) {
                printString += printCategoryToHTML(value);
            });
            printString += "</ul>";
        }
        return printString;
    };

    function ShowCategories(JSONdata) {
        if (JSONdata.meta.code == '200') {
            $("#results").html(printCategoriesToHTML(JSONdata.response));
        }
        else {
            $("#results").html($.printJSONToHTML(JSONdata, 0));
        }
    };

    function GetCategories() {
        // implemented in a cleaner separate url and parameters style
        var requestData = {
            'client_id': '<%:ViewData["FourSquareClientId"]%>',
            'client_secret': '<%:ViewData["FourSquareClientSecret"]%>',
            'v': '20111115'
        };

        $.getJSON('<%:ViewData["FourSquareVenuesUri"]%>/categories?callback=?', requestData, ShowCategories);
    };

    function SearchVenues(lat, long, radius, category, searchTerm) {
        // implemented in a messy "construct the url" style
        var url = '<%:ViewData["FourSquareVenuesUri"]%>' + '/search' +
                    "?client_id=" + '<%:ViewData["FourSquareClientId"]%>' +
                    "&client_secret=" + '<%:ViewData["FourSquareClientSecret"]%>' +
                    "&v=20111115" +
                    "&intent=browse" +
                    "&ll=" + lat + "," + long +
                    ((null == searchTerm) ? "" : ("&query=" + searchTerm)) +
                    ((null == category) ? "" : ("&categoryId=" + category)) +
                    "&radius=" + radius +
                    "&callback=?";
        $.getJSON(url, ShowResponse);
    };

    function GetDetails(venueId) {
        var request = {
            'client_id': '<%:ViewData["FourSquareClientId"]%>',
            'client_secret': '<%:ViewData["FourSquareClientSecret"]%>',
            'v': '20111115',
            'sort' : 'recent'
        };
        $.getJSON('<%:ViewData["FourSquareVenuesUri"]%>/' + venueId + '/tips?callback=?', request, ShowResponse);
        /***
        alert("The results are tips from users. Now see photos");

        request = {
            'client_id': '<%:ViewData["FourSquareClientId"]%>',
            'client_secret': '<%:ViewData["FourSquareClientSecret"]%>',
            'v': '20111115',
            'groups': 'multi'
        };
        $.getJSON('<%:ViewData["FourSquareVenuesUri"]%>/' + venueId + '/photos?callback=?', request, ShowResponse);
        ***/
    };

    function EnableVenuesAPI() {
        $("#VenuesAPI")[0].style.display = "";
        $("#CheckinsAPI")[0].style.display = "none";
    };

    function EnableCheckinsAPI() {
        $("#VenuesAPI")[0].style.display = "none";
        $("#CheckinsAPI")[0].style.display = "";
    };


    </script>

    <p>
        This sample shows how to access information in the FourSquare Venues API.        
        The developer site is <a href="https://developer.foursquare.com/docs/overview.html">here</a>.
        Terms of usage are <a href="http://foursquare.com/legal/api/licenseagreement">here</a>. 
     </p>
     <p>
	If a map is used, the map must be from FourSquare.
        Caching is not disallowed --- in fact, the API includes a feature to make it easier to cache results.
        The usage limit is 500 requests per hour per authenticated user and 5000 requests per hour for "userless" access, but this can be increased by contacting foursquare. 
     </p>
     <p>
     Of particular interest, FourSquare suggests that third parties should use their venues API as their location database. The restriction is that they do not want foursquare venus data to be used to improve competing location databases. 
     </p>
     <p>
        <button id="VenuesButton" onclick="EnableVenuesAPI();">Venues API</button>
        <button id="CheckinsButton" onclick="EnableCheckinsAPI();">Checkins API</button>
     </p>
     <div id="VenuesAPI" style="display:block">
                <script type="text/javascript">
                    // FourSquare Places types/categories can be multi-selected
                    function GetCategoryInput(form) {
                        var returnCategory = null;
                        var i;
                        for (i = 0; i < form.Category.length; i++) {
                            if (form.Category[i].checked) {
                                returnCategory = form.Category[i].value;
                                break;
                            }
                        }
                        return returnCategory;
                    };
                </script>
     <h2> Venues API </h2>
     <table>
        <thead>
            <tr>
            <td>Venue Categories</td>
            <td>Venue Search</td>
            <td>Venue Details (aka Aspects)</td>
            </tr>
        </thead>
        <tbody>
        <tr>
            <td>
                <form action="FourSquare.aspx">
                    <input type="button" value="Get Categories" onclick="GetCategories();" />
                </form>                                 
            </td>
            <td>
                <form action="FourSquare.aspx">
                    Lat : <input type="text" name="Latitude" value="47.607551"/> <br />
                    Long : <input type="text" name="Longitude" value="-122.117597"/> <br />
                    Radius (meters) : <input type="text" name="Radius" value="10000"/> <br />
                    
                    <input type="radio" name="Category" value="4bf58dd8d48988d1e1931735"/> Arcade <br />
                    <input type="radio" name="Category" value="4bf58dd8d48988d1e2931735"/> Art Gallery <br />
                    <input type="radio" name="Category" value="4bf58dd8d48988d1e4931735"/> Bowling Alley <br />
                    <input type="radio" name="Category" value="4bf58dd8d48988d17c941735"/> Casino <br />
                    <input type="radio" name="Category" value="4bf58dd8d48988d18e941735"/> Comedy Club <br />
                    <input type="radio" name="Category" value="4deefb944765f83613cdba6e"/> Historic Site <br />
                    <input type="radio" name="Category" value="4bf58dd8d48988d17f941735"/> Movie Theater<br />
                    <input type="radio" name="Category" value="4bf58dd8d48988d181941735"/> Museum <br />

                    Search term : <input type="text" name="SearchTerm" value=""/> <br />
                                        
                    <input type="button" value="Search" onclick="SearchVenues(this.form.Latitude.value, this.form.Longitude.value, this.form.Radius.value, GetCategoryInput(this.form), this.form.SearchTerm.value);" />
                </form>                                 
            </td>
            <td>
                <form action="FourSquare.aspx">
                    Venue Id : <input type="text" name="VenueId" value="4ac80b62f964a5205abb20e3"/> <br />
                    <input type="button" value="Get Details" onclick="GetDetails(this.form.VenueId.value);" />
                </form>                                 
            </td>
        </tr>
        </tbody>
     </table>
     </div>
     <div id="CheckinsAPI" style="display:none">
     <h2> Checkins/Reports API </h2>
     TODO: The Checkins API allows you to checkin to a location. The Reports API allows you to create new places.
     </div>
     <p>
     <h2>Results</h2>
     </p>
     <div id="results"></div>
    
</asp:Content>
