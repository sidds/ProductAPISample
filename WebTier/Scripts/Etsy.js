
/****
 *** This file contsins js to interact with the Etsy APIs.
 *** Javascript doesn't have true classes or inheritance. However, I'd like to model access to any
 *** retail store in terms of some common classes so that we can separate the specifics of the store from the UI.
 *** So the implementation below models classes and inheritance via existing Javascript mechanisms
 ****/
// requires that we have the UtilNamespace.js already included
if (typeof RetailNamespace == "undefined")
{
    alert("Dev error: Need to include RetailNamespace namespace");
}

// Now define a "class" that implements the interface.
// The class has two pieces ---- a constructor function that defines and sets properties, and method definitions on the function prototype
RetailNamespace.EtsyProvider = function(apiUri, apiKey) {
    this.UrlBase = apiUri;
    this.ApiKey = apiKey;
    this.ActiveListingsUrlExtension = '/listings/active';
    this.CategoriesUrlExtension = '/taxonomy/categories';
    this.ListingImagesUrlExtension = '/listings/{0}/images';
    // assert that EtsyProvider implements IProvider -- this is only checked when the constructor is invoked.
    UTIL.checkInterface(this, RetailNamespace.IProvider);
};

// now add the method definitions. These are done separately outside the constructor
RetailNamespace.EtsyProvider.prototype.GetUrl = function(urlExtension) {
    return this.UrlBase + urlExtension + '.js?callback=?';
};

RetailNamespace.EtsyProvider.prototype.categoryToCanonical= function(etsyCategory) {
    var category = {};
    category.id = etsyCategory.category_id;
    category.name = etsyCategory.name;
    category.description = etsyCategory.meta_description;
    category.subCategories = null; // for the moment
    return category;
};

RetailNamespace.EtsyProvider.prototype.categoriesToCanonical= function(etsyCategoryResults) {
    var categoryResults = {};
    categoryResults.error = (etsyCategoryResults.ok ? null : "error");
    categoryResults.categories = [];
    var this_func = this;
    $.each(etsyCategoryResults.results, function (key, value) {
	    categoryResults.categories.push(this_func.categoryToCanonical(value));
    } );
    return categoryResults;
};

RetailNamespace.EtsyProvider.prototype.GetCategories = function(displayFunction) {
    // alert("Here at EtsyProvider.GetCategories()");
    var requestData = {
	'api_key': this.ApiKey
    };
    var this_func = this;

    $.getJSON(this.GetUrl(this.CategoriesUrlExtension), requestData, function(resultData) {

	// alert($.printableJSON(resultData, 0));
	// first convert the incoming JSON data into the desired canonical form
	var canonicalCategories = this_func.categoriesToCanonical(resultData);

	// then display it
	displayFunction(canonicalCategories);
    });
};

RetailNamespace.EtsyProvider.prototype.GetMetadata = function(displayFunction) {
    var metadataResults = {};
    
    metadataResults.colors = [{name: 'red', id: 'red'}, 
			      {name: 'blue', id: 'blue'},
			      {name: 'green', id: 'green'}];

    metadataResults.sortOrders = [{ name: 'relevance', id: 'score' },
				  {name : 'created', id: 'created'},
				  {name : 'price', id: 'price'}];

    // get category information (asynchronous)
    this.GetCategories(function(categoryResults) {
    	metadataResults.error = categoryResults.error;
        metadataResults.categories = categoryResults.categories;
	// then display it
	displayFunction(metadataResults);
    });

};

RetailNamespace.EtsyProvider.prototype.listingToCanonical = function (etsyListing) {
    var listing = {};
    listing.id = etsyListing.listing_id;
    var this_func = this;
    listing.imageUrl = etsyListing.Images[0].url_75x75;
    listing.title = etsyListing.title;
    listing.totalNew = etsyListing.quantity;
    listing.lowestNewPrice = etsyListing.price;
    listing.lowestNewListingId = etsyListing.listing_id;

    // this is the Url to the forum discussion asking Etsy for anonymous carts
    listing.lowestNewCartUrl = "http://groups.google.com/group/etsy-api-v2/browse_thread/thread/4cea64c1da580ab8/bb7cf908d70b2ab7?lnk=gst&q=get+cart#bb7cf908d70b2ab7";

    // don't know if Etsy has used listings
    listing.totalUsed = 0;
    listing.lowestUsedPrice = "";
    listing.lowestUsedListingId = null;
    listing.lowestUsedCartUrl = null;
    listing.description = etsyListing.description;
    listing.detailsUrl = etsyListing.url;

    return listing;
};

RetailNamespace.EtsyProvider.prototype.listingsToCanonical= function(etsyListingResults) {
    var listingResults = {};
    listingResults.error = (etsyListingResults.ok ? null : "error");
    listingResults.total = etsyListingResults.count;
    listingResults.listings = [];
    var this_func = this;
    $.each(etsyListingResults.results, function (key, value) {
	    listingResults.listings.push(this_func.listingToCanonical(value));
    } );
    return listingResults;
};

RetailNamespace.EtsyProvider.prototype.GetListings = function(category, colors, minReviewAvg, maxPrice, searchTerm, sortOrder, displayFunction) {
    var requestData = {
	'api_key': this.ApiKey,
	'includes': 'Images(url_75x75):1:0'
    };

    if ((null != category) && ("" != category)) {
	requestData.category = category;
    };

    if ((null != colors) && ("" != colors)) {
	// Etsy has a wierd way of defining colors as an RGB, so ignore for now
    }
    if ((null != minReviewAvg) && ("" != minReviewAvg)) {
	// Etsy doesn't support minReviewAverage, so ignore this
    }

    if ((null != maxPrice) && ("" != maxPrice)) {
	requestData.max_price = maxPrice;
    }

    if ((null != searchTerm) && ("" != searchTerm)) {
	requestData.keywords = searchTerm;
    }

    if ((null != sortOrder) && ("" != sortOrder)) {
	requestData.sort_on = sortOrder;
	if ('price' == sortOrder) {
	    requestData.sort_order = 'up';
	}
	else {
	    requestData.sort_order = 'down';
	};
    }
    var this_func = this;

    $.getJSON(this.GetUrl(this.ActiveListingsUrlExtension), requestData, function(resultData) {
	    // alert($.printableJSON(resultData, 0));
	    // first convert the incoming JSON data into the desired canonical form
    	var canonicalListings = this_func.listingsToCanonical(resultData);
	    // then display it
	    displayFunction(canonicalListings);
    });
};

// This method should (a) add the product to an anonymous cart, (b) get the purchaseUrl for this cart, (c) open a window to take the user to
// that url. Unfortunately, Etsy doesn't yet support anonymous carts, though there are asks from it from developers. They only support
// OAuth carts for specific users (i.e. it must already be an Etsy user who has also provided permissions to the app).
RetailNamespace.EtsyProvider.prototype.AddListingToCart = function(listingId, displayFunction) {
    return displayFunction("http://groups.google.com/group/etsy-api-v2/browse_thread/thread/4cea64c1da580ab8/bb7cf908d70b2ab7?lnk=gst&q=get+cart#bb7cf908d70b2ab7");
};
    


