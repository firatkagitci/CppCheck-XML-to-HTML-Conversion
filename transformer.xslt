<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" indent="yes"/>
  <xsl:key name="files" match="error" use="location[1]/@file"/>

  <xsl:template match="/">
    <html>
    <head>
      <title>Static Analysis Dashboard</title>
      <style>
        :root {
          --primary: #2c3e50;
          --secondary: #3498db;
          --error: #e74c3c;
          --warning: #f1c40f;
          --info: #3498db;
          --success: #2ecc71;
        }

        body {
          font-family: 'Segoe UI', system-ui, sans-serif;
          margin: 0;
          /* set a slightly darker grey background for the entire dashboard */
          background: #e1e1e1;
          color: #444;
        }

        .main-content {
          padding: 30px;
        }

        .summary-card {
          background: white;
          border-radius: 10px;
          padding: 20px;
          margin-bottom: 30px;
          box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        }

        .chart-container {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
          gap: 20px;
          margin-top: 20px;
        }

        .chart-card {
          background: white;
          padding: 20px;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .severity-badge {
          display: inline-flex;
          align-items: center;
          padding: 4px 12px;
          border-radius: 20px;
          font-size: 0.9em;
          font-weight: 500;
        }
        .error-error .severity-badge {
          background: var(--error);
          color: #444;
        }
        .error-style .severity-badge {
          background: var(--warning);
          color: black;
        }
        .error-information .severity-badge {
          background: var(--info);
          color: #444;
        }

        .file-section {
          background: white;
          border-radius: 8px;
          margin-bottom: 20px;
          overflow: hidden;
          box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .file-header {
          background: linear-gradient(145deg, #f8f9fa, #ffffff);
          padding: 15px 20px;
          border-bottom: 1px solid #eee;
        }

        .location-link {
          color: #666;
          text-decoration: none;
          display: inline-flex;
          align-items: center;
          gap: 4px;
          padding: 4px 8px;
          border-radius: 4px;
          background: #f8f9fa;
        }
        .location-link:hover {
          background: var(--secondary);
          color: white;
        }

        .file-link {
          /* we can keep the same style if we like, or unify with location-link */
          color: var(--primary);
          text-decoration: none;
          font-weight: 600;
          display: inline-flex;
          align-items: center;
          gap: 8px;
        }
        .file-link:hover {
          color: var(--secondary);
          text-decoration: underline;
        }

        .issue-table {
          width: 100%;
          border-collapse: collapse;
        }
        .issue-table th {
          background: #f8f9fa;
          padding: 12px 15px;
          text-align: left;
          font-size: 0.9em;
          color: #666;
        }
        .issue-table td {
          padding: 12px 15px;
          border-bottom: 1px solid #eee;
          vertical-align: top;
        }
      </style>
    </head>
    <body>
      <div class="main-content">
        <!-- Summary Card -->
        <div class="summary-card">
          <h1 style="margin-top:0;color:var(--primary)">Static Analysis Dashboard</h1>
          <!-- We'll show total files, total issues, and severity distribution together -->
          <div class="chart-container">
            <div class="chart-card">
              <h3>📋 Total Files</h3>
              <div style="font-size:2em;color:var(--primary)">
                <xsl:value-of select="count(//error[generate-id() = generate-id(key('files', location[1]/@file)[1])])"/>
              </div>
            </div>
            <div class="chart-card">
              <h3>⚠️ Total Issues</h3>
              <div style="font-size:2em;color:var(--primary)">
                <xsl:value-of select="count(//error)"/>
              </div>
            </div>
            <div class="chart-card">
              <h3>Severity Distribution</h3>
              <div style="font-size:0.9em;margin-top:15px">
                <div><span style="color: var(--error)">●</span> Errors: <xsl:value-of select="count(//error[@severity='error'])"/></div>
                <div><span style="color: var(--warning)">●</span> Warnings: <xsl:value-of select="count(//error[@severity='style'])"/></div>
                <div><span style="color: var(--info)">●</span> Info: <xsl:value-of select="count(//error[@severity='information'])"/></div>
              </div>
            </div>
          </div>
        </div>
        <!-- End Summary Card -->

        <!-- File Sections -->
        <xsl:for-each select="results/errors/error[generate-id() = generate-id(key('files', location[1]/@file)[1])]">
          <xsl:sort select="location[1]/@file"/>
          <xsl:variable name="currentFile" select="location[1]/@file"/>
          <xsl:if test="$currentFile != ''">
            <div class="file-section">
              <div class="file-header">
                <h3>
                  <!-- Using location-link style, but pointing to line 1 -->
                  <a class="location-link" href="vscode://file/{translate($currentFile, '\\', '/')}:1:1">
                    📄 <xsl:value-of select="$currentFile"/>
                  </a>
                </h3>
              </div>
              <table class="issue-table">
                <tr>
                  <th>Severity</th>
                  <th>Message</th>
                  <th>Location</th>
                  <th>Details</th>
                </tr>
                <xsl:for-each select="key('files', $currentFile)">
                  <xsl:variable name="severityClass">
                    <xsl:choose>
                      <xsl:when test="@severity = 'error'">error-error</xsl:when>
                      <xsl:when test="@severity = 'style'">error-style</xsl:when>
                      <xsl:otherwise>error-information</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <tr class="{$severityClass}">
                    <td>
                      <div class="severity-badge">
                        <xsl:choose>
                          <xsl:when test="@severity = 'error'">⛔</xsl:when>
                          <xsl:when test="@severity = 'style'">⚠️</xsl:when>
                          <xsl:otherwise>ℹ️</xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="@severity"/>
                      </div>
                    </td>
                    <td>
                      <div style="font-weight:500;"><xsl:value-of select="@msg"/></div>
                      <xsl:if test="symbol">
                        <div style="color:var(--primary);font-size:0.9em">
                          🏷️ <xsl:value-of select="symbol"/>
                        </div>
                      </xsl:if>
                    </td>
                    <td>
                      <xsl:for-each select="location">
                        <div style="margin-bottom:8px;">
                          <a class="location-link" href="vscode://file/{translate(@file, '\\', '/')}:{@line}:{@column}">
                            📍 Line <xsl:value-of select="@line"/>:<xsl:value-of select="@column"/>
                          </a>
                        </div>
                      </xsl:for-each>
                    </td>
                    <td>
                      <div style="color:#666;font-size:0.9em">
                        <xsl:if test="contains(@id, 'misra')">
                          <div>🔖 MISRA <xsl:value-of select="substring-after(@id, 'misra-')"/></div>
                        </xsl:if>
                        <xsl:if test="@cwe">
                          <div>🛡️ CWE-<xsl:value-of select="@cwe"/></div>
                        </xsl:if>
                      </div>
                    </td>
                  </tr>
                </xsl:for-each>
              </table>
            </div>
          </xsl:if>
        </xsl:for-each>
      </div>
    </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
