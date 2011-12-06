﻿using System;
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
            ViewData["Logo"] = "../Content/AmazonLogo.jpg";
            ViewData["LogoAltText"] = "Amazon Logo";

            return View("Amazon");
        }

        public ActionResult EBay()
        {
            ViewData["Title"] = "Product APIs";
            ViewData["Header"] = "Google Maps APIs";
            return View("EBay");
        }
    }
}
