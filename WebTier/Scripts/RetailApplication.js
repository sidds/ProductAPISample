/*** 
*** This is included from all of the individual retail pages in the Product API Sample 
***/

function ShowCategories(categoryResults) {
    // alert($.printableJSON(categoryResults, 0));
    // expect this data to conform to a standard Categories "schema"
    if (null == categoryResults.error) {
        $("#ResultsDiv").append(printCategoriesToHTML(categoryResults.categories));
    }
    else {
        $("#ResultsDiv").append($.printJSONToHTML(categoryResults, 0));
    }
    $("#ResultsDiv")[0].style.display = "";
};

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

function addListingToCart(listingId, addToCartUrl) {
    if ((undefined != addToCartUrl) && (typeof addToCartUrl == "function")) {
        addToCartUrl(listingId, purchaseCartWindow);
    }
    else if ((null != addToCartUrl) && (undefined != addToCartUrl)) {
        purchaseCartWindow(addToCartUrl);
    }
}

function makeBuyButtonHTML(buttonText, listingId, addToCartUrl) {
    if (null == listingId) {
        return "";
    }
    else {
        return '<button name="Buy' + listingId + '" onclick="addListingToCart(\'' + listingId + '\',\'' + addToCartUrl + '\');">' + buttonText + '</button>';
    }
};

function clearSearchResults() {
    // $("#ResultsDiv")[0].style.display = "none";
    $("#TotalResults").contents().remove();
    $("#ResultsBody").children().remove();
};

function purchaseCartWindow(purchaseUrl) {
    window.open(purchaseUrl);
};

function ShowListings(listingResults) {

    // alert($.printableJSON(JSONdata, 0));

    if ((null == listingResults) || (typeof listingResults != 'object')) {
        alert("Null object");
        return;
    }

    $("#TotalResults").append(listingResults.total);
    $("#ResultsDiv")[0].style.display = "";

    for (var i in listingResults.listings) {
        var newRow = '<tr name="ResultRow">';
        var listing = listingResults.listings[i];
        if (null != listing) {
            // alert("Listing = " + $.printableJSON(listing, 0));
            newRow += '<td>' + listing.id + '</td>';
            newRow += '<td><image src="' + listing.imageUrl + '"/></td>';
            newRow += '<td>' + listing.totalNew + ' items starting at ' + listing.lowestNewPrice + '</td>';
            newRow += '<td>' + listing.totalUsed + ' items starting at ' + listing.lowestUsedPrice + '</td>';
            newRow += '<td>' + listing.title + '</td>';
            newRow += '<td><a href="' + listing.detailsUrl + '" target="_blank">Product Details</a></td>';
            newRow += '<td>' + makeBuyButtonHTML('Buy New', listing.lowestNewListingId, listing.lowestNewCartUrl) + '</td>';
            newRow += '<td>' + makeBuyButtonHTML('Buy Used', listing.lowestUsedListingId, listing.lowestUsedCartUrl) + '</td>';
            newRow += '</tr>';
            $("#ResultsBody").append(newRow);
        }
    }

};


function populateCategoryChooser(categoryResults) {
    if (null == categoryResults.error) {
        $.each(categoryResults.categories, function (key, value) {
            var category = value;
            $("#CategoryChooser").append('<option value="' + category.name + '"> ' + category.id + '</option>');
        });
    }
};

function populateSearchOptions(metadata) {
    if (null == metadata.error) {
        if (null != metadata.categories) {
            $.each(metadata.categories, function (key, value) {
                var category = value;
                $("#CategoryChooser").append('<option value="' + category.id + '"> ' + category.name + '</option>');
            });
        }
        else {
            alert("Why is this null?");
        }
        if (null != metadata.colors) {
            $.each(metadata.colors, function (key, value) {
                var color = value;
                $("#ColorChooser").append('<option value="' + color.id + '"> ' + color.name + '</option>');
            });
        };
        if (null != metadata.sortOrders) {
            $.each(metadata.sortOrders, function (key, value) {
                var sortOrder = value;
                $("#SortChooser").append('<option value="' + sortOrder.id + '"> ' + sortOrder.name + '</option>');
            });
        };
    };
};


function GetCategory(form) {
    var i;
    for (i = 0; i < form.Category.length; i++) {
        if (form.Category[i].checked) {
            break;
        }
    }
    return form.Category[i].value;
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
