using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ExmStats
{
    public static class StringExtensions
    {
        public static int FindIndexOfEvent(this string s, char c, int n)
        {
            var takeCount = s.TakeWhile(x => (n -= (x == c ? 1 : 0)) > 0).Count();
            return takeCount == s.Length ? -1 : takeCount;
        }
    }
}