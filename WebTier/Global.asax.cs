using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.ServiceModel;
using System.ServiceModel.Routing;
using System.ServiceModel.Activation;
using WcfProductService;

namespace WebTier
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "Default", // Route name
                "{controller}/{action}/{id}", // URL with parameters
                new { controller = "Home", action = "Amazon", id = UrlParameter.Optional }, // Parameter defaults
                new { controller = "^(?!Product).*" } // ensure it falls thru if the base is "Product"
            );

            routes.Add(new ServiceRoute("Product", new WebServiceHostFactory(), typeof(ProductService)));
        }

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();

            RegisterRoutes(RouteTable.Routes);
        }
    }
}