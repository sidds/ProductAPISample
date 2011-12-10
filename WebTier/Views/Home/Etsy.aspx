<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      
<script type="text/javascript" src="/../Scripts/JSONHelp.js"></script>
<script type="text/javascript" src="/../Scripts/UtilNamespace.js"></script>
<script type="text/javascript" src="/../Scripts/RetailNamespace.js"></script>
<script type="text/javascript" src="/../Scripts/Etsy.js"></script>
<script type="text/javascript" src="/../Scripts/RetailApplication.js"></script>
<script type="text/javascript">

  var etsyProvider = new RetailNamespace.EtsyProvider('<%:ViewData["EtsyApiUri"]%>', '<%:ViewData["EtsyApiKey"]%>');

  $(function () {
      // etsyProvider.GetCategories(populateCategoryChooser);
      etsyProvider.GetMetadata(populateSearchOptions);
  });


</script>

<div id="SearchAPI" style="display:block">
    <p>
        This sample shows how to access information in the Etsy API which exposes the product, price, review and store information. 
        The developer site is <a href="http://www.etsy.com/developers">here</a>.
        Terms of usage are <a href="http://www.etsy.com/developers/terms-of-use">here</a>. 
        There are limits of 5 cals per second and 5000 calls per day.
	    Interestingly, there isn't an affiliates program yet! But there are lots of asks for it, so I expect Etsy will add it soon.
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
                Categories are organized in a multi-level hierarchy. Each category result has a title and a hierarchy path. 
                The Etsy API requries multiple calls to retrieve the hierarchy, which I have not implemented here, so only
                showing the top level of the hierarchy.
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
                              <option value=""> Any </option>
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
                              <input type="text" name="MaxPrice" value="50"/>
                            </td>
                         </tr>
                         <tr>
                           <td>
                              Keywords : <input type="text" name="SearchTerm" value="kumihimo necklace"/> <br />
                           </td>
                           <td>
                              Order Results By <br />
                              <select id="SortChooser" class="DropdownList" name="SortOrder">
                              </select>
                           </td>
                         </tr>
                      </tbody>
                    </table>
                    <input type="button" value="Search" 
                           onclick="clearSearchResults();etsyProvider.GetListings(
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
                <form action="Etsy.aspx">
                    <input type="button" value="Get Categories" onclick="etsyProvider.GetCategories(ShowCategories);" />
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
