
/****
*** This file contsins js to interact with the BBY APIs.
*** Javascript doesn't have true classes or inheritance. However, I'd like to model access to any
*** retail store in terms of some common classes so that we can separate the specifics of the store from the UI.
*** So the implementation below models classes and inheritance via existing Javascript mechanisms
****/
// requires that we have the UtilNamespace.js already included
if (typeof RetailNamespace == "undefined") {
    alert("Dev error: Need to include RetailNamespace namespace");
}

// Now define a "class" that implements the interface.
// The class has two pieces ---- a constructor function that defines and sets properties, and method definitions on the function prototype
RetailNamespace.BBYProvider = function (apiUri, apiKey) {
    this.UrlBase = apiUri;
    this.ApiKey = apiKey;
    this.ActiveListingsUrlExtension = '/products';
    this.CategoriesUrlExtension = '/categories';
    this.ListingImagesUrlExtension = '/listings/{0}/images';
    // assert that BBYProvider implements IProvider -- this is only checked when the constructor is invoked.
    UTIL.checkInterface(this, RetailNamespace.IProvider);
};

// now add the method definitions. These are done separately outside the constructor
RetailNamespace.BBYProvider.prototype.GetUrl = function (urlExtension) {
    return this.UrlBase + urlExtension + '?callback=?';
};

RetailNamespace.BBYProvider.prototype.categoryToCanonical = function (bbyCategory) {
    var category = {};
    category.id = bbyCategory.name;
    category.name = bbyCategory.name;
    category.description = bbyCategory.meta_description;
    category.subCategories = bbyCategory.subCategories; // for the moment
    return category;
};

RetailNamespace.BBYProvider.prototype.categoriesToCanonical = function (bbyCategoryResults) {
    var categoryResults = {};
    categoryResults.error = null;
    categoryResults.categories = [];
    var this_func = this;
    $.each(bbyCategoryResults.categories, function (key, value) {
        categoryResults.categories.push(this_func.categoryToCanonical(value));
    });
    return categoryResults;
};

RetailNamespace.BBYProvider.prototype.GetCategories = function (displayFunction) {
    // alert("Here at BBYProvider.GetCategories()");
    var requestData = {
        'apiKey': this.ApiKey,
        'format': 'json'
    };
    var this_func = this;

    $.getJSON(this.GetUrl(this.CategoriesUrlExtension), requestData, function (resultData) {

        // alert($.printableJSON(resultData, 0));
        // first convert the incoming JSON data into the desired canonical form
        var canonicalCategories = this_func.categoriesToCanonical(resultData);

        // then display it
        displayFunction(canonicalCategories);
    });
};

RetailNamespace.BBYProvider.prototype.GetMetadata = function (displayFunction) {
    var metadataResults = {};

    metadataResults.colors = [{ name: 'black', id: 'black' },
			      { name: 'white', id: 'white' },
			      { name: 'silver', id: 'silver'}];

    metadataResults.sortOrders = [{ name: 'price', id: 'salePrice.asc'}];

    // get category information (asynchronous)
    this.GetCategories(function (categoryResults) {
        metadataResults.error = categoryResults.error;
        metadataResults.categories = categoryResults.categories;
        // then display it
        displayFunction(metadataResults);
    });

};

RetailNamespace.BBYProvider.prototype.listingToCanonical = function (bbyListing) {
    var listing = {};
    listing.id = bbyListing.productId;
    var this_func = this;
    listing.imageUrl = bbyListing.thumbnailImage;
    listing.title = bbyListing.name;
    listing.totalNew = 1;
    listing.lowestNewPrice = bbyListing.salePrice;
    listing.lowestNewListingId = bbyListing.productId;
    listing.lowestNewCartUrl = bbyListing.addToCartUrl;
    // don't know if BBY has used listings
    listing.totalUsed = 0;
    listing.lowestUsedPrice = "";
    listing.lowestUsedListingId = null;
    listing.lowestUsedCartUrl = this.addToCartUrl;
    listing.description = bbyListing.description;
    listing.detailsUrl = bbyListing.url;
    listing.customerReviewAverage = bbyListing.customerReviewAverage;
    listing.onlineAvailability = bbyListing.onlineAvailabiity;
    listing.inStoreAvailability = bbyListing.inStoreAvailability;

    return listing;
};

RetailNamespace.BBYProvider.prototype.listingsToCanonical = function (bbyListingResults) {
    var listingResults = {};
    listingResults.error = ((typeof (bbyListingResults.error) == 'undefined') ? null : "error");
    if (null != listingResults.error) {
        listingResults.listings = [];
        listingResults.total = 0;
    }
    else {
        listingResults.listings = [];
        listingResults.total = bbyListingResults.total;
        var this_func = this;
        $.each(bbyListingResults.products, function (key, value) {
            listingResults.listings.push(this_func.listingToCanonical(value));
        });
    };
    return listingResults;
};

RetailNamespace.BBYProvider.prototype.GetListings = function (category, colors, minReviewAvg, maxPrice, searchTerm, sortOrder, displayFunction) {
    var requestData = {
        'apiKey': this.ApiKey,
        'format': 'json'
    };

    if ((null != sortOrder) && ("" != sortOrder)) {
        requestData.sort = sortOrder;
    }

    var queryString = '(';
    var numQueryConditions = 0;

    if ((null != category) && ("" != category)) {
        queryString += ((numQueryConditions > 0) ? '&' : '');
        queryString += 'categoryPath.name=' + category;
        numQueryConditions++;
    };

    if ((null != colors) && ("" != colors)) {
        queryString += ((numQueryConditions > 0) ? '&' : '');
        queryString += 'color in(' + colors + ')';
        numQueryConditions++;
    }
    if ((null != minReviewAvg) && ("" != minReviewAvg)) {
        // BBY doesn't support minReviewAverage, so ignore this
    }

    if ((null != maxPrice) && ("" != maxPrice)) {
        queryString += ((numQueryConditions > 0) ? '&' : '');
        queryString += 'customerReviewAverage>' + minReviewAvg;
        numQueryConditions++;
    }

    if ((null != searchTerm) && ("" != searchTerm)) {
        queryString += ((numQueryConditions > 0) ? '&' : '');
        queryString += 'search=' + searchTerm;
        numQueryConditions++;
    }

    queryString += ')';
    var this_func = this;

    $.getJSON(this.GetUrl(this.ActiveListingsUrlExtension + queryString), requestData, function (resultData) {
        // alert($.printableJSON(resultData, 0));
        // first convert the incoming JSON data into the desired canonical form
        var canonicalListings = this_func.listingsToCanonical(resultData);
        // then display it
        displayFunction(canonicalListings);
    });
};



