using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Configuration;

namespace WebTier.Controllers
{
    [HandleError]
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            ViewData["Title"] = "Home";
            ViewData["Header"] = "Sample Use of Store/Product APIs";
            return View("Index");
        }


        public ActionResult Amazon()
        {
            ViewData["Title"] = "Product APIs";
            ViewData["Header"] = "Amazon Product Advertising APIs";

            return View("Amazon");
        }

        public ActionResult EBay()
        {
            ViewData["Title"] = "Product APIs";
            ViewData["Header"] = "Google Maps APIs";
            ViewData["Logo"]= "../Content/powered-by-google.png";
            ViewData["LogoAltText"] = "Google Logo";
            ViewData["GooglePlacesUri"] = "https://maps.googleapis.com/maps/api/place/search/json";
            ViewData["GooglePlacesKey"] = ConfigurationManager.AppSettings["GooglePlacesKey"];
            return View("EBay");
        }
    }
}
