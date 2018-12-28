<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatsPage.aspx.cs" Inherits="ExmStats.StatsPage" %>
<%@ Import Namespace="ExmStats" %>
<%@ Import Namespace="MongoDB.Driver" %>
<%@ Import Namespace="MongoDB.Bson" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>

<script runat="server">

    protected void Button1_Click(object sender, EventArgs e)
    {
        bool flag = ValidateData(MessageIdTextBox, MessageRootTextBox);

        if (flag)
        {
            RequestMongoData();
            RequestSqlData();
        }

    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!keysEnableCheckBox.Checked)
        {
            textAnalyticsDB.Visible = false;
            analyticsDB.Visible = false;
            textReportingDB.Visible = false;
            reportingDB.Visible = false;
            textUser.Visible = false;
            textPassword.Visible = false;
            user.Visible = false;
            password.Visible = false;
        }
        else
        {
            textAnalyticsDB.Visible = true;
            analyticsDB.Visible = true;
            textReportingDB.Visible = true;
            reportingDB.Visible = true;
            textUser.Visible = true;
            textPassword.Visible = true;
            user.Visible = true;
            password.Visible = true;
        }
    }

    private void RequestSqlData()
    {
        using (SqlConnection myConnection = new SqlConnection(getSQLConnectionString()))
        {
            string requestToSql = String.Format("Select * FROM [dbo].[ReportDataView] WHERE [SegmentId] = '7558FC89-C25F-4606-BBC5-43B91A382AC9' and DimensionKey like '%{0}%'", IntegrateMessageIDandRoot());
            SqlCommand cmd = new SqlCommand(requestToSql, myConnection);
            myConnection.Open();

            using (SqlDataReader oReader = cmd.ExecuteReader())
            {
                while (oReader.Read())
                {
                    string dimensionkey = oReader["DimensionKey"].ToString();
                    string visitsRowValue = oReader["Visits"].ToString();
                    string countRowValue = oReader["Count"].ToString();
                    string eventOfRow = FindEventInDimensionKey(dimensionkey);
                    CheckRowEventType(eventOfRow, visitsRowValue, countRowValue);
                }

                myConnection.Close();
            }
        }
    }

    private void RequestMongoData()
    {
        string connectionString = ConfigurationManager.ConnectionStrings["analytics"].ConnectionString;
        MongoUrl mongoUrl = new MongoUrl(connectionString);
        var server = new MongoClient(connectionString).GetServer();
        var db = server.GetDatabase(mongoUrl.DatabaseName);
        //
        var col = db.GetCollection<BsonDocument>("Interactions");
        var mongoInteractionsList = CreateMongoInteractionsList();
        var mongoControlsList = CreateMongoControlsList();
        for (int i = 0; i < mongoInteractionsList.Count; i++)
        {
            IMongoQuery mongoQuery = MongoDB.Driver.Builders.Query.EQ("Pages.PageEvents.Name", mongoInteractionsList[i]);
            IMongoQuery mongoQuery2 = MongoDB.Driver.Builders.Query.Matches("Pages.PageEvents.Data", new BsonRegularExpression(MessageIdTextBox.Text));
            IMongoQuery interSectionQuery = MongoDB.Driver.Builders.Query.And(mongoQuery, mongoQuery2);
            var resultQuery = col.Find(interSectionQuery);
            mongoControlsList[i].Text = resultQuery.ToList().Count.ToString();
            //
        }
    }

    private string getSQLConnectionString()
    {
        if (reportingDB.Text.Length > 1)
        {
            return String.Format("Initial Catalog={0};Integrated Security=False;User ID={1};Password={2}", reportingDB.Text, user.Text, password.Text);
        }
        else
        {
            return ConfigurationManager.ConnectionStrings["reporting"].ConnectionString;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        #form1 {
            height: 366px;
            width: 793px;
        }
		#table {
            text-align:center;
        }
    </style>
</head>
<body style="height: 675px">
    <form id="form1" runat="server">
    <div>
        <p>
        Message Root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox ID="MessageRootTextBox" runat="server" Width="324px"></asp:TextBox>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </p>
        Message ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:TextBox ID="MessageIdTextBox" runat="server" Width="322px"></asp:TextBox>
        </div>

         <p>
                <asp:Label runat="server" Text="Checkin if databases do not belong to the current solution and you want to set their names manually:"/>          
                <asp:CheckBox runat="server" Text=" " ID="keysEnableCheckBox"/>
             </p><p>
                <asp:Button runat="server" Text="Confirm checkbox changing" />
            </p>
            
            <p>
                <asp:Label runat="server" ID="textAnalyticsDB" AssociatedControlID="analyticsDB" Text="Analytics database: " />
                <asp:TextBox runat="server" TextMode="SingleLine" ID="analyticsDB" Width="222px" />
            </p>
                <asp:Label runat="server" ID="textReportingDB" AssociatedControlID="reportingDB" Text="Reporting database: " />
                <asp:TextBox runat="server" TextMode="SingleLine" ID="reportingDB" Width="216px" />
                <asp:Label runat="server" ID="textUser" AssociatedControlID="User" Text="SQL User: " />
                <asp:TextBox runat="server" TextMode="SingleLine" ID="user" Width="90px" />
                <asp:Label runat="server" ID="textPassword" AssociatedControlID="password" Text="SQL Password: " />
                <asp:TextBox runat="server" TextMode="SingleLine" ID="password" Width="93px" />

                 <br />
        <br /> <br />
        <br />
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Check databases statistics" Height="48px" Width="318px" />
         
        <br />
        <br />
        <table style="width:40%">
  <tr>
    <th></th>
    <th>Analytics</th> 
    <th>Reporting</th>
  </tr>
  <tr>
    <td>Sent</td>
    <td id="table"><asp:Label ID="Label9" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label1" runat="server" Text="-"></asp:Label></td>
  </tr>
  <tr>
    <td>Opened</td>
    <td id="table"><asp:Label ID="Label10" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label2" runat="server" Text="-"></asp:Label></td>
  </tr>
  <tr>
    <td>Clicked</td>
    <td id="table"><asp:Label ID="Label11" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label3" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Unique Opened</td>
    <td id="table"><asp:Label ID="Label12" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label4" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Unique Clicked</td>
    <td id="table"><asp:Label ID="Label13" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label5" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Bounced</td>
    <td id="table"><asp:Label ID="Label14" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label6" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Unsubscribed</td>
    <td id="table"><asp:Label ID="Label15" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label7" runat="server" Text="-"></asp:Label></td>
  </tr>
            <tr>
    <td>Bounced</td>
    <td id="table"><asp:Label ID="Label16" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label8" runat="server" Text="-"></asp:Label></td>
  </tr>

</table>
        
        </div>
    </form>
</body>
</html>
