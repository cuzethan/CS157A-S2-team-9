<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  request.setAttribute("pageTitle", "SJSUMarketplace");
%>
<%@ include file="/WEB-INF/jsp/layout/header.jsp" %>

<div
  class="fixed inset-0 -z-10"
  style="background-image: url('<%= request.getContextPath() %>/assets/sjsu-background.png'); background-size: cover; background-position: center;"
></div>
<div class="fixed inset-0 -z-10 bg-slate-900/45"></div>

<div class="min-h-[70vh] flex items-center justify-center py-12">
  <div class="w-full max-w-2xl bg-white/90 backdrop-blur rounded-2xl shadow-lg px-8 py-10 text-center">
    <h2 class="text-4xl sm:text-6xl font-extrabold tracking-tight text-slate-900">
      Welcome To SJSUMarketplace
    </h2>
    <p class="mt-4 text-base sm:text-lg text-slate-700">
      A place to buy and sell with fellow Spartans!
    </p>

    <div class="mt-8 flex flex-wrap justify-center gap-3">
      <a href="<%= request.getContextPath() %>/login"
         class="inline-flex items-center justify-center rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-semibold text-white hover:bg-blue-700">
        Login
      </a>
      <a href="<%= request.getContextPath() %>/signup"
         class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-5 py-2.5 text-sm font-semibold text-slate-800 hover:bg-slate-50">
        Sign up
      </a>
      <a href="<%= request.getContextPath() %>/listings"
         class="inline-flex items-center justify-center rounded-lg border border-slate-300 bg-white px-5 py-2.5 text-sm font-semibold text-slate-800 hover:bg-slate-50">
        Browse listings
      </a>
    </div>
  </div>
</div>


<%@ include file="/WEB-INF/jsp/layout/footer.jsp" %>

