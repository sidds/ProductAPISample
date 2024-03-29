<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<script type="text/javascript" src="/../Scripts/JSONHelp.js"></script>
<script type="text/javascript" src="/../Scripts/UtilNamespace.js"></script>
<script type="text/javascript" src="/../Scripts/RetailNamespace.js"></script>
<script type="text/javascript" src="/../Scripts/BBY.js"></script>
<script type="text/javascript" src="/../Scripts/RetailApplication.js"></script>
<script type="text/javascript">

  var bbyProvider = new RetailNamespace.BBYProvider('<%:ViewData["BBYOpenUri"]%>', 
						    '<%:ViewData["BBYApiKey"]%>');

  $(function () {
      bbyProvider.GetMetadata(populateSearchOptions);
  });

</script>

<div id="SearchAPI" style="display:block">
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
             <b>Search the online store</b><br />
              There are a large number of attributes that can be queried. Here are just a few examples ...
            </td>
            <td>
            <b>Categories</b> <br />
                        Categories are organized in a multi-level hierarchy. Each category result has a
                        title and a hierarchy path. Since each call ony returns 10 results (with a link
                        to the next page), the category hierarchy is not complete. It needs to be reconstrucuted
                        as a tree for pretty printing (have not done that here).
            </td>
            </tr>
        </thead>
        <tbody>
        <tr>
            <td> 
                <form action="Etsy.aspx">
                    <table>
                      <tbody>
                         <tr>
                            <td>
                              Category <br />
                              <select id="CategoryChooser" class="DropdownList" name="Category">
                              <option value="Cameras*"> Cameras </option>
                              <option value="Computers & Tablets*"> Computers </option>
                              <option value="TV*"> TV and Video </option>
                              </select>
                            </td>
                            <td>
                              Color <br />
                              <select id="ColorChooser" class="DropdownList" name="Color">
                              <option value=""> Any </option>
                              </select>
                            </td>
                         </tr>
                         <tr>
                            <td>
                              MinReviewAverage
                              <input type="text" name="MinReviewAverage" value="3"/>
                            </td>
                            <td>
                              MaxPrice USD
                              <input type="text" name="MaxPrice" value="100"/>
                            </td>
                         </tr>
                         <tr>
                           <td>
                              Keywords : <input type="text" name="SearchTerm" value="digital SLR camera bag"/> <br />
                           </td>
                           <td>
                              Order Results By <br />
                              <select id="SortChooser" class="DropdownList" name="SortOrder">
                              <option value=""> Any </option>
                              </select>
                           </td>
                         </tr>
                      </tbody>
                    </table>
                    <input type="button" value="Search" 
                           onclick="clearSearchResults();bbyProvider.GetListings(
                                                              this.form.CategoryChooser.value, 
                                                              GetColor(this.form), 
                                                              this.form.MinReviewAverage.value, 
                                                              this.form.MaxPrice.value, 
                                                              this.form.SearchTerm.value,
                                                              this.form.SortOrder.value,
                                                              ShowListings);" />
                </form> 
            </td>
            <td>
                <form action="BestBuy.aspx">
                    <input type="button" value="Get Categories" onclick="bbyProvider.GetCategories(ShowCategories);" />
                </form>                                 
            </td>
        </tr>
        </tbody>
     </table>
     </div>

     <p/>
     <h2>Results</h2>
     
     <div id="ResultsDiv" style="display:none">
        Total Results = <span id="TotalResults"></span>
        <table>
            <thead>
                <tr>
                    <td>Id</td>
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
