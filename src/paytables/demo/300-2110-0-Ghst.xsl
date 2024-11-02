<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson">
<lxslt:script lang="javascript">
					
					// Limited to 50 strings of Debuging
					var debugFeed = [];
					var debugFlag = false;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, convertedPrizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var gameData = scenario.split('|');
						var gridCols = gameData[0].split(',');
						var gameTurns = gameData[1].split(',');
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						//var maxColLength = getMaxColLength(gridCols);
						
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
						// Print Translation Table to !DEBUG
						var index = 1;
						registerDebugText("Translation Table");
						while(index &lt; translations.item(0).getChildNodes().getLength())
						{
							var childNode = translations.item(0).getChildNodes().item(index);
							registerDebugText(childNode.getAttribute("key") + ": " +  childNode.getAttribute("value"));
							index += 2;
						}
						
						// !DEBUG
						//registerDebugText("Translating the text \"softwareId\" to \"" + getTranslationByName("softwareId", translations) + "\"");
						///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					
						// Output winning numbers table.
						var r = [];
						var shownWin = [false,false,false,false,false];
						var showWin = false;
						var prizeText = '';

						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablebody"&gt;');
									r.push(getTranslationByName("outcomes", translations));
								r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');
						r.push('&lt;/table&gt;');

						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');

							for (turn=1, totals=[0,0,0,0,0], totalStr='', extraTurn=false, totalIndex=-1, totalTurn=0, winTotals=[30,28,25,20,15], instantWins=[], instantWin=false; turn&lt;=gameTurns.length; turn++)
							{
								r.push('&lt;tr&gt;');
									r.push('&lt;td class="tablehead" width="20%"&gt;');
										r.push(getTranslationByName("turn", translations) + ' ' + turn);
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead" width="20%"&gt;');
										r.push(getTranslationByName("emoticon", translations));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead" width="20%"&gt;');
										r.push(getTranslationByName("numberCollected", translations));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead" width="20%"&gt;');
										r.push(getTranslationByName("cumulativeTotal", translations));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead" width="20%"&gt;');
										r.push(getTranslationByName("prize", translations));
									r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');

								extraTurn = false;
								instantWin = false;
								totalTurn = 0;

								if (isNaN(parseInt(gameTurns[turn-1])))
								{
									totalIndex = gameTurns[turn-1].charCodeAt(0) - 'A'.charCodeAt(0);

									for (col=0; col&lt;gridCols.length; col++)
									{
										for (colCell=0; colCell&lt;6; colCell++)
										{
											if (gridCols[col][colCell] == gameTurns[turn-1].toLowerCase())
											{
												extraTurn = true;
											}

											if (gridCols[col][colCell].toUpperCase() == gameTurns[turn-1])
											{
												totalTurn++;
												totals[totalIndex]++;
											}
										}

										var turnRegExp = new RegExp(gameTurns[turn-1], 'gi');
										gridCols[col] = gridCols[col].substr(0,6).replace(turnRegExp,'') + gridCols[col].substr(6);
									}
								}
								else
								{
									instantWins.push(gameTurns[turn-1]);
									instantWin = true;
								}

								for (symb=0; symb&lt;totals.length; symb++)
								{
									prizeText = String.fromCharCode('A'.charCodeAt(0) + symb);
									showWin = ((totals[symb] &gt;= winTotals[symb]) &amp;&amp; !shownWin[symb]);
									//showWin = true;

									r.push('&lt;tr&gt;');
										r.push('&lt;td class="tablebody"&gt;');
											r.push('&amp;nbsp;');
										r.push('&lt;/td&gt;');
										r.push('&lt;td class="tablebody"&gt;');
											r.push(getTranslationByName("symb" + prizeText, translations));
										r.push('&lt;/td&gt;');
										r.push('&lt;td class="tablebody"&gt;');
											r.push(((symb == totalIndex) ? totalTurn : '0'));
										r.push('&lt;/td&gt;');
										r.push('&lt;td class="tablebody"&gt;');
											r.push(totals[symb] + '/' + winTotals[symb] + ' ' + ((showWin) ? getTranslationByName("win", translations) : ''));
										r.push('&lt;/td&gt;');
										r.push('&lt;td class="tablebody"&gt;');
											r.push(((showWin) ? prizeValues[prizeNames.indexOf(prizeText)] : ''));
										r.push('&lt;/td&gt;');
									r.push('&lt;/tr&gt;');

									if (showWin)
									{
										shownWin[symb] = true;
									}
								}

								r.push('&lt;tr&gt;');
									r.push('&lt;td class="tablehead"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead"&gt;');
										r.push(getTranslationByName("extras", translations));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead" colspan="2"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablehead"&gt;');
										r.push(getTranslationByName("prize", translations));
									r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');

								r.push('&lt;tr&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push(getTranslationByName("instantWin", translations));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push(((instantWin) ? '1' : '0'));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody" colspan="2"&gt;');
										r.push(((instantWin) ? prizeValues[prizeNames.indexOf('IW' + instantWins[instantWins.length-1])] : ''));
									r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');

								r.push('&lt;tr&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push(getTranslationByName("extraTurn", translations));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push(((extraTurn) ? '1' : '0'));
									r.push('&lt;/td&gt;');
									r.push('&lt;td class="tablebody" colspan="2"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');

								r.push('&lt;tr&gt;');
									r.push('&lt;td class="tablebody"&gt;');
										r.push('&amp;nbsp;');
									r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
							}
						
						r.push('&lt;/table&gt;');					
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							for(var idx = 0; idx &lt; debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablebody"&gt;');
								r.push(debugFeed[idx]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
							}
							r.push('&lt;/table&gt;');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" &amp;&amp; childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeTable" select="lxslt:nodeset(//lottery)"/>
<xsl:variable name="convertedPrizeValues">
<xsl:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
</xsl:variable>
<xsl:variable name="prizeNames">
<xsl:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="prize" mode="PrizeValue">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="text()"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</xsl:template>
<xsl:template match="description" mode="PrizeDescriptions">
<xsl:text>,</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
