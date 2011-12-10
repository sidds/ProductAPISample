
// requires that we have the UtilNamespace.js already included
if (typeof UTIL == "undefined")
{
    alert("Dev error: Need to include UTIL namespace");
}

// Define a "namespace" for retail data providers
var RetailNamespace = {};

// Define an "interface" for a retail provider
RetailNamespace.IProvider = {
    UrlBase: '',
    GetUrl: function (urlExtension) { },
    GetCategories: function (displayFunction) { },
    GetMetadata: function (displayFunction) { },
    GetListings: function (category, colors, minReviewAvg, maxPrice, searchTerm, sortOrder, displayFunction) { },
};

/******* 
 **** Now try to use something loosely modeled on JSONSchema (draft stage standard) to capture the key Retail concepts **
 **** Will eventually convert it to actual JSONSchema.
 ****/

RetailNamespace.MetadataSchema = {
    'error' : { 'type' : 'string' },
    'categories' : {
	'type' : 'array',
	'items' : {
	    'type' : 'CategorySchema'
	}
    },
    'colors' : {
	'type' : 'array',
	'items' : {
	    'type' : 'string'
	}
    },
    'sortorders' : {
	'type' : 'array',
	'items' : {
	    'type' : 'string'
	}
    }
};


RetailNamespace.CategorySchema = {
    'id' : { 'type' : 'string' },
    'name' : { 'type' : 'string' },
    'description' : { 'type' : 'string' },
    'subCategories' : {
	'type' : 'array',
	'items' : {
	    'type' : 'CategorySchema'
	}
    }
};

RetailNamespace.CategoryResultsSchema = {
    'error' : { 'type' : 'string' },
    'categories' : {
	'type' : 'array',
	'items' : {
	    'type' : 'CategorySchema'
	}
    }
};

RetailNamespace.ListingSchema = {
    'id' : { 'type' : 'string' },
    'imageUrl' : { 'type' : 'string' },
    'title' : { 'type' : 'string' },
    'description' : { 'type' : 'string' },
    'detailsUrl' : { 'type' : 'string' },
    'totalNew' : { 'type' : 'integer' },
    'lowestNewPrice' : { 'type' : 'float' },
    'lowestNewListingId' : { 'type' : 'string' },
    'lowestNewCartUrl' : { 'type' : 'string' },
    'totalUsed' : { 'type' : 'integer' },
    'lowestUsedPrice' : { 'type' : 'float' },
    'lowestUsedListingId' : { 'type' : 'string' },
    'lowestUsedCartUrl' : { 'type' : 'string' }
};

RetailNamespace.ListingResultsSchema = {
    'error' : { 'type' : 'string' },
    'listings' : {
	'type' : 'array',
	'items' : {
	    'type' : 'ListingSchema'
	}
    }
};